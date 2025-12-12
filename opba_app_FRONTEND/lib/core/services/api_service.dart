import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// API istekleri için temel servis sınıfı
/// JWT token yönetimi, hata yakalama ve interceptor'lar içerir
class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // API Base URL - Gerçek projenizde environment variable kullanın
  static const String baseUrl = 'https://localhost:5002/api';
  
  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    _initializeInterceptors();
  }

  /// Interceptor'ları başlat
  void _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Her istekte JWT token'ı ekle
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Response başarılı
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          // 401 hatası - Token geçersiz
          if (error.response?.statusCode == 401) {
            // Token'ı temizle ve login'e yönlendir
            await clearToken();
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// JWT Token'ı secure storage'a kaydet
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: 'jwt_token', value: token);
    } catch (e) {
      throw ApiException('Token kaydedilemedi: $e');
    }
  }

  /// JWT Token'ı secure storage'dan al
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: 'jwt_token');
    } catch (e) {
      return null;
    }
  }

  /// JWT Token'ı temizle
  Future<void> clearToken() async {
    try {
      await _secureStorage.delete(key: 'jwt_token');
    } catch (e) {
      throw ApiException('Token temizlenemedi: $e');
    }
  }

  /// GET isteği
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException('Beklenmeyen hata: $e');
    }
  }

  /// POST isteği
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
      );
      
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException('Beklenmeyen hata: $e');
    }
  }

  /// PUT isteği
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
      );
      
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException('Beklenmeyen hata: $e');
    }
  }

  /// DELETE isteği
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(endpoint);
      
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException('Beklenmeyen hata: $e');
    }
  }

  /// Response'u işle ve ApiResponse'a çevir
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      T? data;
      
      if (fromJson != null && response.data != null) {
        data = fromJson(response.data as Map<String, dynamic>);
      }
      
      return ApiResponse<T>(
        success: true,
        data: data,
        message: response.data['message'] ?? 'İşlem başarılı',
      );
    } else {
      throw ApiException(
        response.data['message'] ?? 'Bir hata oluştu',
        statusCode: response.statusCode,
      );
    }
  }

  /// DioException'ları işle
  ApiException _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.',
          statusCode: error.response?.statusCode,
        );
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data['message'] ?? 'Bir hata oluştu';
        
        switch (statusCode) {
          case 400:
            return ApiException('Geçersiz istek: $message', statusCode: 400);
          case 401:
            return ApiException('Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.', statusCode: 401);
          case 403:
            return ApiException('Bu işlem için yetkiniz yok.', statusCode: 403);
          case 404:
            return ApiException('İstenilen kaynak bulunamadı.', statusCode: 404);
          case 500:
            return ApiException('Sunucu hatası. Lütfen daha sonra tekrar deneyin.', statusCode: 500);
          default:
            return ApiException(message, statusCode: statusCode);
        }
      
      case DioExceptionType.cancel:
        return ApiException('İstek iptal edildi.');
      
      case DioExceptionType.connectionError:
        return ApiException(
          'İnternet bağlantınızı kontrol edin ve tekrar deneyin.',
        );
      
      default:
        return ApiException('Beklenmeyen bir hata oluştu: ${error.message}');
    }
  }
}

/// API Response modeli
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
  });
}

/// API Exception sınıfı
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
