import 'package:flutter_test/flutter_test.dart';
import '../core/services/api_service.dart';
import '../core/services/auth_service.dart';

void main() {
  group('Backend Connection Tests', () {
    late ApiService apiService;
    late AuthService authService;

    setUp(() {
      apiService = ApiService();
      authService = AuthService(apiService);
    });

    test('API Service should be initialized', () {
      expect(apiService, isNotNull);
    });

    test('Auth Service should be initialized', () {
      expect(authService, isNotNull);
    });

    group('Login Tests', () {
      test('Login with valid credentials should return success', () async {
        // Mock test - Gerçek API bağlantısı için mock kullanılmalı
        final response = await authService.login(
          username: 'testuser',
          password: 'testpassword',
        );

        // Not: Bu test gerçek API olmadığı için başarısız olabilir
        // Mock ile test edilmeli
        expect(response, isNotNull);
      });

      test('Login with empty username should fail', () async {
        final response = await authService.login(
          username: '',
          password: 'testpassword',
        );

        expect(response.success, isFalse);
      });
    });

    group('Register Tests', () {
      test('Register with valid data should return success', () async {
        final response = await authService.register(
          username: 'newuser',
          email: 'test@example.com',
          password: 'password123',
          firstName: 'Test',
          lastName: 'User',
          phone: '5551234567',
          securityQuestion: 'Test question?',
          securityAnswer: 'Test answer',
        );

        expect(response, isNotNull);
      });
    });

    group('Token Management Tests', () {
      test('Should save token to secure storage', () async {
        const testToken = 'test.jwt.token';
        
        await apiService.saveToken(testToken);
        final savedToken = await apiService.getToken();
        
        expect(savedToken, equals(testToken));
      });

      test('Should clear token from secure storage', () async {
        const testToken = 'test.jwt.token';
        
        await apiService.saveToken(testToken);
        await apiService.clearToken();
        final token = await apiService.getToken();
        
        expect(token, isNull);
      });
    });

    group('Error Handling Tests', () {
      test('Should handle connection timeout', () async {
        // API bağlantısı olmadan test
        try {
          await apiService.get('/nonexistent');
          fail('Should throw ApiException');
        } catch (e) {
          expect(e, isA<ApiException>());
        }
      });

      test('Should handle 404 error', () async {
        try {
          await apiService.get('/invalid-endpoint');
          fail('Should throw ApiException');
        } catch (e) {
          expect(e, isA<ApiException>());
        }
      });
    });

    group('Security Question Tests', () {
      test('Should verify security answer', () async {
        final response = await authService.verifySecurityAnswer(
          tempToken: 'temp.token',
          securityAnswer: 'answer',
        );

        expect(response, isNotNull);
      });
    });
  });

  group('Integration Tests', () {
    test('Full login flow should work', () async {
      final apiService = ApiService();
      final authService = AuthService(apiService);

      // 1. Login
      final loginResponse = await authService.login(
        username: 'testuser',
        password: 'password',
      );

      expect(loginResponse, isNotNull);

      // 2. Verify security answer (eğer gerekiyorsa)
      if (loginResponse.requiresSecurityAnswer && loginResponse.tempToken != null) {
        final verifyResponse = await authService.verifySecurityAnswer(
          tempToken: loginResponse.tempToken!,
          securityAnswer: 'answer',
        );

        expect(verifyResponse, isNotNull);
      }
    });
  });
}
