# OPBA - Açık Bankacılık Mobil Uygulaması

Flutter ile geliştirilmiş açık bankacılık mobil uygulaması.

## 🚀 Özellikler

Bu proje aşağıdaki özellikleri içerir:

### ✅ Tamamlanan Özellikler

1. **Profil Ekranı UI**
   - Kullanıcı bilgileri görüntüleme
   - Profil düzenleme seçeneği
   - Güvenlik ayarları
   - Çıkış yapma

2. **Flutter API Servis Base Sınıfı**
   - Dio tabanlı HTTP client
   - Interceptor desteği
   - Otomatik JWT token yönetimi
   - Hata yönetimi ve logging

3. **Login / Register / Security Question API Entegrasyonu**
   - Kullanıcı kayıt ekranı
   - İki aşamalı giriş sistemi
   - Güvenlik sorusu doğrulama
   - Şifre sıfırlama

4. **JWT Token Güvenli Saklama**
   - flutter_secure_storage ile şifreli saklama
   - Otomatik token yenileme
   - Oturum yönetimi

5. **Backend Bağlantı Testleri**
   - Unit testler
   - Integration testler
   - Mock API testleri

6. **Hata Yönetimi**
   - Global error handling
   - Kullanıcı dostu hata mesajları
   - Network hatası yönetimi
   - 401, 403, 404, 500 hata kodları

## 📁 Proje Yapısı

```
lib/
├── core/
│   ├── providers/
│   │   └── auth_provider.dart          # State management
│   └── services/
│       ├── api_service.dart            # Base API service
│       └── auth_service.dart           # Auth işlemleri
├── features/
│   ├── auth/
│   │   └── screens/
│   │       ├── login_screen.dart       # Giriş ekranı
│   │       ├── register_screen.dart    # Kayıt ekranı
│   │       └── security_question_screen.dart
│   ├── home/
│   │   └── screens/
│   │       └── home_screen.dart        # Ana sayfa
│   └── profile/
│       └── screens/
│           └── profile_screen.dart     # Profil ekranı
└── main.dart                           # App entry point

test/
└── backend_connection_test.dart        # Backend testleri
```

## 🛠️ Kullanılan Teknolojiler

- **Flutter** - Cross-platform framework
- **Provider** - State management
- **Dio** - HTTP client
- **flutter_secure_storage** - Güvenli veri saklama
- **shared_preferences** - Local storage

## 📦 Kurulum

1. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

2. Uygulamayı çalıştırın:
```bash
flutter run
```

3. Testleri çalıştırın:
```bash
flutter test
```

## 🔐 API Konfigürasyonu

API base URL'ini değiştirmek için `lib/core/services/api_service.dart` dosyasındaki `baseUrl` değişkenini düzenleyin:

```dart
static const String baseUrl = 'https://your-api-url.com/v1';
```

**ÖNEMLİ:** Production ortamında environment variable kullanın!

## 🔑 Güvenlik

- JWT tokenlar `flutter_secure_storage` ile şifreli saklanır
- Şifreler backend'de hash'lenir (frontend'de asla saklanmaz)
- HTTPS protokolü kullanılır
- Güvenlik sorusu ile iki faktörlü doğrulama

## 📱 Ekran Görüntüleri

### Login Ekranı
- Kullanıcı adı ve şifre girişi
- Şifremi unuttum linki
- Kayıt ol seçeneği

### Güvenlik Sorusu Ekranı
- İki aşamalı doğrulama
- Güvenlik sorusu cevaplama

### Ana Sayfa
- Toplam bakiye kartı
- Hızlı işlemler
- Alt navigasyon menüsü

### Profil Ekranı
- Kullanıcı bilgileri
- Ayarlar
- Çıkış yapma

## 🧪 Test Senaryoları

### Backend Bağlantı Testleri
- ✅ API servis başlatma
- ✅ Login işlemi
- ✅ Register işlemi
- ✅ Token yönetimi
- ✅ Hata yönetimi
- ✅ Güvenlik sorusu doğrulama

## 🔄 State Management

Provider pattern kullanılarak state yönetimi yapılır:

```dart
// AuthProvider kullanımı
final authProvider = Provider.of<AuthProvider>(context);

// Login
await authProvider.login(
  username: 'user',
  password: 'pass',
);

// Kullanıcı bilgisi
final user = authProvider.currentUser;
```

## 🚧 Yakında Eklenecek Özellikler

- [ ] Banka hesabı ekleme
- [ ] Harcama takibi
- [ ] Kategori analizi
- [ ] Bütçe yönetimi
- [ ] Kredi karşılaştırma
- [ ] Dil seçimi (TR/EN)
- [ ] Para birimi çevirimi
- [ ] Bildirim sistemi

## 📞 İletişim

Proje hakkında sorularınız için:
- Email: support@opba.com
- GitHub Issues

## 📄 Lisans

Bu proje eğitim amaçlı geliştirilmiştir.

---

**Not:** Bu proje gereksinim analizi dokümanına göre geliştirilmiştir. Backend API'nin hazır olması gerekmektedir.
