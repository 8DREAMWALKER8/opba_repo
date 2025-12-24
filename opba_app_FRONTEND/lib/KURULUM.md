# 🚀 OPBA Kurulum ve Çalıştırma Kılavuzu

Bu kılavuz OPBA mobil uygulamasını geliştirme ortamınızda çalıştırmanız için gerekli adımları içerir.

## 📋 Gereksinimler

### Sistem Gereksinimleri
- **İşletim Sistemi**: Windows 10+, macOS 10.14+, veya Linux
- **RAM**: En az 8GB (16GB önerilir)
- **Disk Alanı**: En az 10GB boş alan

### Yazılım Gereksinimleri
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0.0 veya üzeri)
- [Dart SDK](https://dart.dev/get-dart) (Flutter ile birlikte gelir)
- [Git](https://git-scm.com/downloads)
- [Android Studio](https://developer.android.com/studio) veya [VS Code](https://code.visualstudio.com/)
- Android SDK (Android Studio ile birlikte gelir)
- Xcode (macOS için iOS geliştirme)

---

## 🔧 Kurulum Adımları

### 1. Flutter SDK Kurulumu

#### Windows
```bash
# Flutter SDK'yı indirin ve C:\src\flutter dizinine çıkarın
# Sistem PATH değişkenine ekleyin: C:\src\flutter\bin

# PowerShell'de kontrol edin
flutter doctor
```

#### macOS/Linux
```bash
# Terminal'de Flutter'ı indirin
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# PATH'e ekleyin (.zshrc veya .bashrc)
export PATH="$PATH:$HOME/development/flutter/bin"

# Kontrol edin
flutter doctor
```

### 2. Android Studio Kurulumu

1. [Android Studio](https://developer.android.com/studio)'yu indirin ve kurun
2. Android Studio'yu açın ve SDK Manager'dan gerekli bileşenleri yükleyin:
   - Android SDK Platform-Tools
   - Android SDK Build-Tools
   - Android Emulator

3. Flutter ve Dart plugin'lerini yükleyin:
   - `Settings` > `Plugins` > `Flutter` arayın ve yükleyin
   - Dart otomatik olarak gelecektir

### 3. Proje Kurulumu

```bash
# Proje dizinine gidin
cd opba_app

# Bağımlılıkları yükleyin
flutter pub get

# Flutter doctor ile kontrol edin
flutter doctor -v
```

---

## 📱 Cihaz Hazırlama

### Android Emulator

1. Android Studio'da `AVD Manager`'ı açın
2. `Create Virtual Device` tıklayın
3. Bir cihaz seçin (örn: Pixel 6)
4. Sistem imajı indirin (API 30 veya üzeri önerilir)
5. Emulator'ü başlatın

```bash
# Komut satırından emulator başlatma
flutter emulators
flutter emulators --launch <emulator_id>
```

### Fiziksel Android Cihaz

1. Ayarlar > Geliştirici Seçenekleri > USB Hata Ayıklama'yı açın
2. Cihazı USB ile bilgisayara bağlayın
3. Cihazda USB hata ayıklama iznini onaylayın

```bash
# Bağlı cihazları kontrol edin
flutter devices
```

### iOS Simulator (macOS)

```bash
# iOS Simulator'ü başlatın
open -a Simulator

# Veya Flutter ile
flutter emulators
flutter emulators --launch apple_ios_simulator
```

---

## ▶️ Uygulamayı Çalıştırma

### Debug Mode

```bash
# Varsayılan cihazda çalıştır
flutter run

# Belirli bir cihazda çalıştır
flutter run -d <device_id>

# Hot reload ile çalıştır (önerilir)
flutter run --hot
```

### Release Mode

```bash
# Android için
flutter build apk --release
flutter build appbundle --release

# iOS için (macOS gerekli)
flutter build ios --release
```

---

## 🧪 Test Çalıştırma

```bash
# Tüm testleri çalıştır
flutter test

# Belirli bir test dosyası
flutter test test/backend_connection_test.dart

# Coverage ile
flutter test --coverage
```

---

## 🔍 Hata Ayıklama

### Flutter Doctor Sorunları

```bash
# Tüm sorunları kontrol et
flutter doctor -v

# Android license sorunları
flutter doctor --android-licenses

# Cache temizle
flutter clean
flutter pub get
```

### Build Hataları

```bash
# Cache temizle ve yeniden build et
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

### Dependency Sorunları

```bash
# Pub cache temizle
flutter pub cache repair

# Bağımlılıkları güncelle
flutter pub upgrade --major-versions
```

---

## 🌐 API Konfigürasyonu

### Backend URL Değiştirme

`lib/core/services/api_service.dart` dosyasını açın:

```dart
static const String baseUrl = 'http://localhost:3000/v1'; // Development
// static const String baseUrl = 'https://api.opba.com/v1'; // Production
```

### Environment Variables (Önerilen)

1. `.env` dosyası oluşturun:
```env
API_BASE_URL=http://localhost:3000/v1
API_TIMEOUT=30
```

2. `pubspec.yaml`'a ekleyin:
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

3. Kullanım:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load();
final baseUrl = dotenv.env['API_BASE_URL'];
```

---

## 📊 Geliştirme Araçları

### VS Code Extensions (Önerilen)

- Flutter
- Dart
- Flutter Widget Snippets
- Error Lens
- GitLens

### Android Studio Plugins

- Flutter
- Dart
- ADB Idea
- Flutter Enhancement Suite

### Debugging Tools

```bash
# Flutter DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Widget Inspector
# Debug modda çalıştırırken DevTools'u açın
```

---

## 🔐 Güvenlik Notları

### API Keys ve Secrets

1. **Asla** API key'leri kod içine yazmayın
2. `.env` dosyası kullanın
3. `.env` dosyasını `.gitignore`'a ekleyin
4. Production için environment variables kullanın

### Secure Storage

```bash
# flutter_secure_storage platformlara göre farklı şifreleme kullanır
# Android: EncryptedSharedPreferences
# iOS: Keychain
```

---

## 📦 Build ve Dağıtım

### Android APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APK (daha küçük boyut)
flutter build apk --split-per-abi --release

# APK konumu
build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (Google Play için)

```bash
flutter build appbundle --release

# AAB konumu
build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
# iOS build (macOS gerekli)
flutter build ios --release

# IPA oluşturma
# Xcode'da Archive > Distribute App
```

---

## 🐛 Sık Karşılaşılan Sorunlar

### Problem: "flutter: command not found"
**Çözüm**: Flutter'ın PATH'e eklendiğinden emin olun

### Problem: "Gradle build failed"
**Çözüm**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Problem: "Waiting for another flutter command to release the startup lock"
**Çözüm**:
```bash
# Windows
taskkill /F /IM dart.exe

# macOS/Linux
killall -9 dart
```

### Problem: iOS build hatası
**Çözüm**:
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

---

## 📚 Ek Kaynaklar

- [Flutter Dokümantasyonu](https://docs.flutter.dev/)
- [Dart Dokümantasyonu](https://dart.dev/guides)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Flutter YouTube Kanalı](https://www.youtube.com/c/flutterdev)

---

## 💬 Destek

Sorun yaşıyorsanız:
1. `flutter doctor -v` çıktısını kontrol edin
2. GitHub Issues'da arama yapın
3. Stack Overflow'da sorun

---

## ✅ Kontrol Listesi

- [ ] Flutter SDK kuruldu
- [ ] Android Studio kuruldu
- [ ] `flutter doctor` başarılı
- [ ] Emulator/Cihaz hazır
- [ ] `flutter pub get` çalıştırıldı
- [ ] Uygulama başarıyla çalışıyor
- [ ] Backend API yapılandırıldı
- [ ] Testler çalışıyor

---

**İyi geliştirmeler! 🎉**
