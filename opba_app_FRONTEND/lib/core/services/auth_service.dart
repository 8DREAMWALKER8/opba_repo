import '../services/api_service.dart';

/// Kimlik doğrulama işlemleri için servis sınıfı
class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  /// Kullanıcı kayıt
  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'securityQuestion': securityQuestion,
          'securityAnswer': securityAnswer,
        },
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final token = response.data!['token'] as String?;
        final user = User.fromJson(response.data!['user']);
        
        if (token != null) {
          await _apiService.saveToken(token);
        }
        
        return AuthResponse(
          success: true,
          message: response.message,
          user: user,
          token: token,
        );
      }

      return AuthResponse(
        success: false,
        message: response.message,
      );
    } on ApiException catch (e) {
      return AuthResponse(
        success: false,
        message: e.message,
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Kayıt işlemi sırasında bir hata oluştu: $e',
      );
    }
  }

  /// Kullanıcı girişi (İlk adım - kullanıcı adı ve şifre kontrolü)
  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final securityQuestion = response.data!['securityQuestion'] as String?;
        final tempToken = response.data!['tempToken'] as String?;
        
        return AuthResponse(
          success: true,
          message: response.message,
          securityQuestion: securityQuestion,
          tempToken: tempToken,
          requiresSecurityAnswer: true,
        );
      }

      return AuthResponse(
        success: false,
        message: response.message,
      );
    } on ApiException catch (e) {
      return AuthResponse(
        success: false,
        message: e.message,
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Giriş işlemi sırasında bir hata oluştu: $e',
      );
    }
  }

  /// Güvenlik sorusu cevabı doğrulama (İkinci adım)
  Future<AuthResponse> verifySecurityAnswer({
    required String tempToken,
    required String securityAnswer,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/auth/verify-security',
        data: {
          'tempToken': tempToken,
          'securityAnswer': securityAnswer,
        },
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final token = response.data!['token'] as String?;
        final user = User.fromJson(response.data!['user']);
        
        if (token != null) {
          await _apiService.saveToken(token);
        }
        
        return AuthResponse(
          success: true,
          message: response.message,
          user: user,
          token: token,
        );
      }

      return AuthResponse(
        success: false,
        message: response.message,
      );
    } on ApiException catch (e) {
      return AuthResponse(
        success: false,
        message: e.message,
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Doğrulama sırasında bir hata oluştu: $e',
      );
    }
  }

  /// Şifre sıfırlama talebi
  Future<AuthResponse> forgotPassword({required String email}) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/auth/forgot-password',
        data: {'email': email},
        fromJson: (json) => json,
      );

      return AuthResponse(
        success: response.success,
        message: response.message,
      );
    } on ApiException catch (e) {
      return AuthResponse(
        success: false,
        message: e.message,
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Şifre sıfırlama talebi sırasında bir hata oluştu: $e',
      );
    }
  }

  /// Çıkış yap
  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout');
    } catch (e) {
      // Logout hatası olsa bile token'ı temizle
    } finally {
      await _apiService.clearToken();
    }
  }

  /// Oturum kontrolü
  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Kullanıcı bilgilerini al
  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/auth/me',
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        return User.fromJson(response.data!);
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}

/// Kullanıcı modeli
class User {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? profileImage;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.profileImage,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'],
      profileImage: json['profileImage'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';
}

/// Auth işlemleri için response modeli
class AuthResponse {
  final bool success;
  final String message;
  final User? user;
  final String? token;
  final String? tempToken;
  final String? securityQuestion;
  final bool requiresSecurityAnswer;

  AuthResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
    this.tempToken,
    this.securityQuestion,
    this.requiresSecurityAnswer = false,
  });
}
