/// Form validation fonksiyonları
class Validators {
  /// E-posta validasyonu
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi gerekli';
    }
    
    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    
    return null;
  }

  /// Şifre validasyonu
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    
    if (value.length < minLength) {
      return 'Şifre en az $minLength karakter olmalı';
    }
    
    // Güçlü şifre kontrolü (opsiyonel)
    // if (!value.contains(RegExp(r'[A-Z]'))) {
    //   return 'Şifre en az bir büyük harf içermeli';
    // }
    // if (!value.contains(RegExp(r'[a-z]'))) {
    //   return 'Şifre en az bir küçük harf içermeli';
    // }
    // if (!value.contains(RegExp(r'[0-9]'))) {
    //   return 'Şifre en az bir rakam içermeli';
    // }
    
    return null;
  }

  /// Şifre eşleşme kontrolü
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı gerekli';
    }
    
    if (value != originalPassword) {
      return 'Şifreler eşleşmiyor';
    }
    
    return null;
  }

  /// Kullanıcı adı validasyonu
  static String? username(String? value, {int minLength = 3, int maxLength = 20}) {
    if (value == null || value.isEmpty) {
      return 'Kullanıcı adı gerekli';
    }
    
    if (value.length < minLength) {
      return 'Kullanıcı adı en az $minLength karakter olmalı';
    }
    
    if (value.length > maxLength) {
      return 'Kullanıcı adı en fazla $maxLength karakter olabilir';
    }
    
    // Sadece harf, rakam ve alt çizgi
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Kullanıcı adı sadece harf, rakam ve alt çizgi içerebilir';
    }
    
    return null;
  }

  /// Telefon numarası validasyonu (Türkiye)
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon numarası gerekli';
    }
    
    // Boşluk, tire ve parantezleri kaldır
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Türkiye telefon numarası formatı: 5XXXXXXXXX (10 haneli)
    if (!RegExp(r'^5[0-9]{9}$').hasMatch(cleanedValue)) {
      return 'Geçerli bir telefon numarası girin (5XX XXX XX XX)';
    }
    
    return null;
  }

  /// IBAN validasyonu (Türkiye)
  static String? iban(String? value) {
    if (value == null || value.isEmpty) {
      return 'IBAN gerekli';
    }
    
    // Boşlukları kaldır ve büyük harfe çevir
    final cleanedValue = value.replaceAll(' ', '').toUpperCase();
    
    // TR ile başlamalı ve 26 karakter olmalı
    if (!cleanedValue.startsWith('TR') || cleanedValue.length != 26) {
      return 'Geçerli bir TR IBAN numarası girin (26 karakter)';
    }
    
    // IBAN karakterleri sadece harf ve rakam olmalı
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(cleanedValue)) {
      return 'IBAN sadece harf ve rakam içerebilir';
    }
    
    return null;
  }

  /// Required field validasyonu
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName gerekli' : 'Bu alan gerekli';
    }
    return null;
  }

  /// Minimum uzunluk kontrolü
  static String? minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // required validator ile kullanılmalı
    }
    
    if (value.length < minLength) {
      final field = fieldName ?? 'Bu alan';
      return '$field en az $minLength karakter olmalı';
    }
    
    return null;
  }

  /// Maksimum uzunluk kontrolü
  static String? maxLength(String? value, int maxLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    if (value.length > maxLength) {
      final field = fieldName ?? 'Bu alan';
      return '$field en fazla $maxLength karakter olabilir';
    }
    
    return null;
  }

  /// Sayısal değer kontrolü
  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    if (double.tryParse(value) == null) {
      final field = fieldName ?? 'Bu alan';
      return '$field sayısal bir değer olmalı';
    }
    
    return null;
  }

  /// Minimum değer kontrolü
  static String? minValue(String? value, num minValue, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    final numValue = num.tryParse(value);
    if (numValue == null) {
      return 'Geçerli bir sayı girin';
    }
    
    if (numValue < minValue) {
      final field = fieldName ?? 'Değer';
      return '$field en az $minValue olmalı';
    }
    
    return null;
  }

  /// Maksimum değer kontrolü
  static String? maxValue(String? value, num maxValue, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    final numValue = num.tryParse(value);
    if (numValue == null) {
      return 'Geçerli bir sayı girin';
    }
    
    if (numValue > maxValue) {
      final field = fieldName ?? 'Değer';
      return '$field en fazla $maxValue olabilir';
    }
    
    return null;
  }

  /// Tarih validasyonu
  static String? date(String? value, {DateTime? minDate, DateTime? maxDate}) {
    if (value == null || value.isEmpty) {
      return 'Tarih gerekli';
    }
    
    final date = DateTime.tryParse(value);
    if (date == null) {
      return 'Geçerli bir tarih girin';
    }
    
    if (minDate != null && date.isBefore(minDate)) {
      return 'Tarih ${_formatDate(minDate)} tarihinden sonra olmalı';
    }
    
    if (maxDate != null && date.isAfter(maxDate)) {
      return 'Tarih ${_formatDate(maxDate)} tarihinden önce olmalı';
    }
    
    return null;
  }

  /// URL validasyonu
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Geçerli bir URL girin';
    }
    
    return null;
  }

  /// Birden fazla validator'ı birleştir
  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  /// Tarih formatla (yardımcı fonksiyon)
  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

/// Validator kullanım örnekleri:
/// 
/// TextFormField(
///   validator: Validators.email,
/// )
/// 
/// TextFormField(
///   validator: (value) => Validators.password(value, minLength: 8),
/// )
/// 
/// TextFormField(
///   validator: (value) => Validators.combine(value, [
///     Validators.required,
///     (v) => Validators.minLength(v, 5),
///     (v) => Validators.maxLength(v, 20),
///   ]),
/// )
