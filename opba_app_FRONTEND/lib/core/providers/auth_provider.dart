import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

/// Authentication state management
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  String? _tempToken;
  String? _securityQuestion;

  AuthProvider(this._authService);

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  String? get securityQuestion => _securityQuestion;

  /// Kullanıcı kayıt
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _authService.register(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        securityQuestion: securityQuestion,
        securityAnswer: securityAnswer,
      );

      if (response.success) {
        _currentUser = response.user;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Kayıt sırasında bir hata oluştu: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Kullanıcı giriş (İlk adım)
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _authService.login(
        username: username,
        password: password,
      );

      if (response.success && response.requiresSecurityAnswer) {
        _tempToken = response.tempToken;
        _securityQuestion = response.securityQuestion;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Giriş sırasında bir hata oluştu: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Güvenlik sorusu cevabı doğrula (İkinci adım)
  Future<bool> verifySecurityAnswer(String answer) async {
    if (_tempToken == null) {
      _error = 'Oturum bilgisi bulunamadı. Lütfen tekrar giriş yapın.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _error = null;

    try {
      final response = await _authService.verifySecurityAnswer(
        tempToken: _tempToken!,
        securityAnswer: answer,
      );

      if (response.success) {
        _currentUser = response.user;
        _tempToken = null;
        _securityQuestion = null;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Doğrulama sırasında bir hata oluştu: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Şifre sıfırlama talebi
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _authService.forgotPassword(email: email);
      
      if (!response.success) {
        _error = response.message;
      }
      
      notifyListeners();
      return response.success;
    } catch (e) {
      _error = 'Şifre sıfırlama talebi sırasında bir hata oluştu: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Çıkış yap
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authService.logout();
      _currentUser = null;
      _tempToken = null;
      _securityQuestion = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Çıkış sırasında bir hata oluştu: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Oturum kontrolü yap
  Future<void> checkAuthStatus() async {
    _setLoading(true);

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      
      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        _currentUser = user;
      } else {
        _currentUser = null;
      }
      
      notifyListeners();
    } catch (e) {
      _currentUser = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Hata mesajını temizle
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Loading durumunu güncelle
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
