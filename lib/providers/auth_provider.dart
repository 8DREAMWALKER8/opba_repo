import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  AuthProvider() {
    _checkAuthStatus();
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
      await Future.delayed(const Duration(seconds: 1));

      _tempUserId = 'user_123';
      _securityQuestion = 'Annenizin kızlık soyadı nedir?';

      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Giriş başarısız. Lütfen bilgilerinizi kontrol edin.';
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
      await Future.delayed(const Duration(seconds: 1));

      _token = 'demo_token_${DateTime.now().millisecondsSinceEpoch}';
      _user = User(
        id: _tempUserId,
        username: 'demo_user',
        email: 'demo@opba.com',
        name: 'Ahmet Yılmaz',
        securityQuestion: _securityQuestion ?? '',
        language: 'tr',
        currency: 'TRY',
        theme: 'light',
      );

      await _storage.write(key: 'auth_token', value: _token);
      await _storage.write(key: 'user_id', value: _user!.id);

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Güvenlik sorusu cevabı yanlış.';
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
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      _token = 'demo_token_${DateTime.now().millisecondsSinceEpoch}';
      _user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        username: username,
        email: email,
        phone: phone,
        securityQuestion: securityQuestion,
        language: 'tr',
        currency: 'TRY',
        theme: 'light',
      );

      await _storage.write(key: 'auth_token', value: _token);
      await _storage.write(key: 'user_id', value: _user!.id);

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Kayıt başarısız. Lütfen tekrar deneyin.';
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
    String? name,
    String? email,
    String? phone,
    String? language,
    String? currency,
    String? theme,
  }) async {
    if (_user == null) return false;

    try {
      _user = _user!.copyWith(
        name: name ?? _user!.name,
        email: email ?? _user!.email,
        phone: phone ?? _user!.phone,
        language: language ?? _user!.language,
        currency: currency ?? _user!.currency,
        theme: theme ?? _user!.theme,
      );
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
