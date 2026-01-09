import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opba_app/services/api_service.dart';
import '../models/user_model.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _token;
  String? _tempUserId;
  String? _securityQuestion;
  String? _error;

  final _storage = const FlutterSecureStorage();

  AuthStatus get status => _status;
  User? get user => _user;
  String? get token => _token;
  String? get securityQuestion => _securityQuestion;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  List<Map<String, dynamic>> _securityQuestions = [];
  bool _securityQuestionsLoaded = false;

  List<Map<String, dynamic>> get securityQuestions => _securityQuestions;
  bool get securityQuestionsLoaded => _securityQuestionsLoaded;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> initSecurityQuestions(
      {String lang = 'tr', bool force = false}) async {
    // Daha önce yüklediysek tekrar istek atma
    if (_securityQuestionsLoaded && !force) return;

    try {
      final api = ApiService();

      final resp = await api.getSecurityQuestions(lang: lang);

      // Beklenen response örneği:
      // { ok: true, lang: 'tr', questions: [ {id:'q1', text:'...'}, ... ] }
      final ok = resp is Map && resp['ok'] == true;
      if (!ok) {
        // ok false ise cache'i bozma; sadece loaded flag'i false bırak
        _securityQuestionsLoaded = false;
        notifyListeners();
        return;
      }

      final questions = (resp['questions'] as List?) ?? [];
      _securityQuestions =
          questions.map((e) => Map<String, dynamic>.from(e as Map)).toList();

      _securityQuestionsLoaded = true;
      notifyListeners();
    } catch (e) {
      _securityQuestionsLoaded = false;
      // İstersen burada loglayabilirsin
      notifyListeners();
    }
  }

  // İstersen id ile tek soru metni bulma (UI tarafını kolaylaştırır)
  String? securityQuestionTextById(String id) {
    final q = _securityQuestions.where((x) => x['id'] == id).toList();
    if (q.isEmpty) return null;
    return q.first['text']?.toString();
  }

  Future<void> _checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'auth_token');
      final userId = await _storage.read(key: 'user_id');

      if (token != null && userId != null) {
        _token = token;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<bool> login(String emailOrUsername, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final api = ApiService();

      // Backend email bekliyor; username girilirse 400 alırsın.
      final result = await api.login(emailOrUsername.trim(), password);

      final ok = result is Map && result['ok'] == true;
      final message = result is Map ? (result['message'] ?? '').toString() : '';

      if (!ok) {
        _error = message.isNotEmpty ? message : 'Giriş başarısız.';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      debugPrint('login result => ' + result.toString());
      final userId = (result['userId'] ?? '').toString();
      final securityQuestionId =
          (result['securityQuestionId'] ?? '').toString();

      if (userId.isEmpty) {
        _error = 'Giriş doğrulama anahtarı alınamadı.';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      // 2. adım için geçici olarak sakla
      await _storage.write(key: 'user_id', value: userId);
      await _storage.write(
          key: 'security_question_id', value: securityQuestionId);

      _securityQuestion = securityQuestionTextById(securityQuestionId);
      _tempUserId = null; // backend artık userId dönmüyor; token içinde var

      // Henüz authenticated değiliz; güvenlik sorusu adımı var
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message; // "Invalid credentials" gelir
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifySecurityAnswer(String answer) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final api = ApiService();

      final tempUserId = await _storage.read(key: 'user_id');
      if (tempUserId == null || tempUserId.isEmpty) {
        _error = 'Bir yanlışlık oldu, Lütfen tekrar giriş yapın.';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      // 1) verify
      final verifyRes = await api.verifySecurityQuestion(tempUserId, answer);

      final verifyOk = verifyRes is Map && verifyRes['ok'] == true;
      final verifyMsg =
          verifyRes is Map ? (verifyRes['message'] ?? '').toString() : '';

      if (!verifyOk) {
        _error = verifyMsg.isNotEmpty ? verifyMsg : 'Güvenlik cevabı yanlış.';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      final accessToken = verifyRes['token']?.toString() ?? '';
      if (accessToken.isEmpty) {
        _error = 'Access token alınamadı.';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      // 2) token kaydet
      _token = accessToken;
      await _storage.write(key: 'auth_token', value: accessToken);

      // 3) /me çağır ve user setle
      final meRes = await api.getMe();

      final meOk = meRes['ok'] == true;
      final meMsg = (meRes['message'] ?? '').toString();
      if (!meOk) {
        _error = meMsg.isNotEmpty ? meMsg : 'Kullanıcı bilgileri alınamadı.';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      final userJson = meRes['user'];
      if (userJson is! Map<String, dynamic>) {
        _error = 'Kullanıcı verisi beklenmeyen formatta.';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
      debugPrint('USER JSON: ' + userJson.toString());
      // User modelin hangi alanları bekliyorsa ona göre map et
      _user = User.fromJson(userJson); // Eğer fromJson yoksa aşağıya bak

      // user_id storage
      final userId = (userJson['_id'] ?? userJson['id'])?.toString();
      if (userId != null) {
        await _storage.write(key: 'user_id', value: userId);
      }

      debugPrint('user PAYLOAD => ${userJson.toString()}');
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirm,
    required String securityQuestionId,
    required String securityAnswer,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final api = ApiService();

      final result = await api.register({
        'username': username,
        'email': email,
        'phone': phone,
        'password': password,
        'passwordConfirm': passwordConfirm,
        'securityQuestionId': securityQuestionId,
        'securityAnswer': securityAnswer,
      });
      debugPrint('REGISTER PAYLOAD => $securityQuestionId');
      final ok = result is Map && result['ok'] == true;
      final message = result is Map ? (result['message'] ?? '').toString() : '';
      final userId = result is Map ? result['userId']?.toString() : null;

      if (!ok) {
        _error = message.isNotEmpty ? message : 'Kayıt başarısız.';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      if (userId != null) {
        await _storage.write(key: 'user_id', value: userId);
      }

      _status = AuthStatus.unauthenticated; // register token dönmüyor
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    _user = null;
    _token = null;
    _tempUserId = null;
    _securityQuestion = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? fullName, // UI'dan geliyor; backend "username" bekliyor
    String? email,
    String? phone,
    String? language,
    String? currency,
    String? theme,
    String? currentPassword,
    String? password,
    String? securityQuestionId,
    String? securityAnswer,
    String? newAnswer,
  }) async {
    if (_user == null) return false;

    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final api = ApiService();

      // Backend profile endpoint sadece username/email/phone güncelliyor
      final result = await api.patchProfile(
        fullName: fullName, // fullName'i username'e map ediyoruz
        email: email,
        phone: phone,
        password: password,
        currentPassword: currentPassword,
        securityQuestionId: securityQuestionId,
        securityAnswer: securityAnswer,
        newAnswer: newAnswer,
        language: language,
        currency: currency,
        theme: theme,
      );

      final ok = result is Map && result['ok'] == true;
      final message = result is Map ? (result['message'] ?? '').toString() : '';

      if (!ok) {
        _error = message.isNotEmpty ? message : 'Profil güncellenemedi.';
        _status = AuthStatus.authenticated;
        notifyListeners();
        return false;
      }

      final userJson = result['user'];
      if (userJson is Map) {
        // User modelinde fromJson varsa onu kullan
        // _user = User.fromJson(Map<String, dynamic>.from(userJson));

        // fromJson yoksa minimum alanlarla set et:

        debugPrint('Profile update json: ' + userJson.toString());
        final m = Map<String, dynamic>.from(userJson);
        _user = _user!.copyWith(
            username: (m['username'] ?? _user!.username).toString(),
            email: (m['email'] ?? _user!.email).toString(),
            phone: (m['phone'] ?? _user!.phone).toString(),
            currency: (m['currency'] ?? _user!.currency).toString(),
            language: (m['language'] ?? _user!.language).toString(),
            theme: (m['theme'] ?? _user!.theme).toString(),
            securityQuestionId:
                (m['securityQuestionId'] ?? _user!.securityQuestionId)
                    .toString(),
            securityQuestion: securityQuestionTextById(
                    (m['securityQuestionId'] ?? _user!.securityQuestionId)
                        .toString()) ??
                _user!.securityQuestion);

        // (opsiyonel) storage user_id güncelle
        final userId = (m['_id'] ?? m['id'])?.toString();
        if (userId != null && userId.isNotEmpty) {
          await _storage.write(key: 'user_id', value: userId);
          await _storage.write(
              key: 'security_question_id',
              value: (m['securityQuestionId'] ?? _user!.securityQuestionId)
                  .toString());
        }
      }

      // Backend bu endpointte language/currency/theme güncellemiyor.
      // Onlar için PATCH /me/settings kullanman gerekir.
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
