import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

/// Merkezi hata yönetimi sınıfı
class ErrorHandler {
  /// Hata mesajını kullanıcıya göster (SnackBar)
  static void showErrorSnackBar(
    BuildContext context,
    dynamic error, {
    Duration duration = const Duration(seconds: 4),
  }) {
    final message = _getErrorMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Başarı mesajını göster
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Bilgi mesajını göster
  static void showInfoSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Hata dialog'u göster
  static Future<void> showErrorDialog(
    BuildContext context,
    dynamic error, {
    String? title,
    VoidCallback? onRetry,
  }) async {
    final message = _getErrorMessage(error);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600),
            const SizedBox(width: 12),
            Text(title ?? 'Hata'),
          ],
        ),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: const Text('Tekrar Dene'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  /// Hatadan kullanıcı dostu mesaj üret
  static String _getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    } else if (error is String) {
      return error;
    } else if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    } else {
      return 'Beklenmeyen bir hata oluştu';
    }
  }

  /// Network hatası kontrolü
  static bool isNetworkError(dynamic error) {
    if (error is ApiException) {
      return error.message.contains('İnternet') ||
          error.message.contains('bağlantı') ||
          error.message.contains('timeout');
    }
    return false;
  }

  /// Auth hatası kontrolü (401)
  static bool isAuthError(dynamic error) {
    if (error is ApiException) {
      return error.statusCode == 401;
    }
    return false;
  }

  /// Validation hatası kontrolü (400)
  static bool isValidationError(dynamic error) {
    if (error is ApiException) {
      return error.statusCode == 400;
    }
    return false;
  }

  /// Server hatası kontrolü (500)
  static bool isServerError(dynamic error) {
    if (error is ApiException) {
      return error.statusCode != null && error.statusCode! >= 500;
    }
    return false;
  }
}

/// Form validation error mesajları
class ValidationMessages {
  static const String requiredField = 'Bu alan zorunludur';
  static const String invalidEmail = 'Geçerli bir e-posta adresi girin';
  static const String invalidPhone = 'Geçerli bir telefon numarası girin';
  static const String passwordTooShort = 'Şifre en az 6 karakter olmalı';
  static const String passwordsNotMatch = 'Şifreler eşleşmiyor';
  static const String usernameTooShort = 'Kullanıcı adı en az 3 karakter olmalı';
  static const String invalidIBAN = 'Geçerli bir IBAN numarası girin';
  
  static String minLength(int length) => 'En az $length karakter olmalı';
  static String maxLength(int length) => 'En fazla $length karakter olabilir';
  static String minValue(num value) => 'Minimum değer $value olmalı';
  static String maxValue(num value) => 'Maksimum değer $value olabilir';
}

/// Loading overlay göster
class LoadingOverlay {
  static OverlayEntry? _overlay;

  static void show(BuildContext context, {String? message}) {
    hide(); // Önceki overlay'i temizle
    
    _overlay = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlay!);
  }

  static void hide() {
    _overlay?.remove();
    _overlay = null;
  }
}

/// Retry mekaniği için utility
class RetryHelper {
  /// Exponential backoff ile retry
  static Future<T> retryWithBackoff<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        
        if (attempt >= maxAttempts) {
          rethrow;
        }

        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }
  }
}

/// Logger utility
class AppLogger {
  static bool _isDebugMode = true;

  static void setDebugMode(bool enabled) {
    _isDebugMode = enabled;
  }

  static void log(String message, {String? tag}) {
    if (_isDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('$prefix$message');
    }
  }

  static void error(String message, {dynamic error, StackTrace? stackTrace}) {
    if (_isDebugMode) {
      debugPrint('❌ ERROR: $message');
      if (error != null) {
        debugPrint('Error details: $error');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  static void warning(String message) {
    if (_isDebugMode) {
      debugPrint('⚠️ WARNING: $message');
    }
  }

  static void info(String message) {
    if (_isDebugMode) {
      debugPrint('ℹ️ INFO: $message');
    }
  }

  static void success(String message) {
    if (_isDebugMode) {
      debugPrint('✅ SUCCESS: $message');
    }
  }
}
