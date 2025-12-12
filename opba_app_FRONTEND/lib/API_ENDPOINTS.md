# OPBA Backend API Endpoints Dokümantasyonu

Bu döküman, OPBA mobil uygulaması için gerekli backend API endpoint'lerini açıklar.

## Base URL
```
https://api.opba.com/v1
```

## Authentication

Tüm korumalı endpoint'ler için `Authorization` header'ı gereklidir:
```
Authorization: Bearer {jwt_token}
```

---

## 🔐 Auth Endpoints

### 1. Kullanıcı Kayıt

**POST** `/auth/register`

#### Request Body
```json
{
  "username": "string",
  "email": "string",
  "password": "string",
  "firstName": "string",
  "lastName": "string",
  "phone": "string",
  "securityQuestion": "string",
  "securityAnswer": "string"
}
```

#### Response (Success - 201)
```json
{
  "success": true,
  "message": "Kayıt başarılı",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "string",
      "username": "string",
      "email": "string",
      "firstName": "string",
      "lastName": "string",
      "phone": "string",
      "profileImage": "string|null",
      "createdAt": "2025-01-15T10:30:00Z"
    }
  }
}
```

#### Response (Error - 400)
```json
{
  "success": false,
  "message": "Kullanıcı adı zaten kullanılıyor"
}
```

---

### 2. Kullanıcı Giriş (1. Adım)

**POST** `/auth/login`

#### Request Body
```json
{
  "username": "string",
  "password": "string"
}
```

#### Response (Success - 200)
```json
{
  "success": true,
  "message": "Kullanıcı doğrulandı",
  "data": {
    "tempToken": "temp.jwt.token.for.verification",
    "securityQuestion": "İlk evcil hayvanınızın adı neydi?"
  }
}
```

#### Response (Error - 401)
```json
{
  "success": false,
  "message": "Kullanıcı adı veya şifre hatalı"
}
```

---

### 3. Güvenlik Sorusu Doğrulama (2. Adım)

**POST** `/auth/verify-security`

#### Request Body
```json
{
  "tempToken": "string",
  "securityAnswer": "string"
}
```

#### Response (Success - 200)
```json
{
  "success": true,
  "message": "Giriş başarılı",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "string",
      "username": "string",
      "email": "string",
      "firstName": "string",
      "lastName": "string",
      "phone": "string",
      "profileImage": "string|null",
      "createdAt": "2025-01-15T10:30:00Z"
    }
  }
}
```

#### Response (Error - 401)
```json
{
  "success": false,
  "message": "Güvenlik sorusu cevabı yanlış"
}
```

---

### 4. Şifre Sıfırlama Talebi

**POST** `/auth/forgot-password`

#### Request Body
```json
{
  "email": "string"
}
```

#### Response (Success - 200)
```json
{
  "success": true,
  "message": "Şifre sıfırlama linki e-postanıza gönderildi"
}
```

---

### 5. Çıkış Yap

**POST** `/auth/logout`

**Requires:** Authorization header

#### Response (Success - 200)
```json
{
  "success": true,
  "message": "Çıkış başarılı"
}
```

---

### 6. Kullanıcı Bilgilerini Al

**GET** `/auth/me`

**Requires:** Authorization header

#### Response (Success - 200)
```json
{
  "success": true,
  "data": {
    "id": "string",
    "username": "string",
    "email": "string",
    "firstName": "string",
    "lastName": "string",
    "phone": "string",
    "profileImage": "string|null",
    "createdAt": "2025-01-15T10:30:00Z"
  }
}
```

---

## 🏦 Bank Account Endpoints (Gelecek için hazır)

### 1. Hesap Ekle

**POST** `/accounts`

**Requires:** Authorization header

#### Request Body
```json
{
  "bankName": "string",
  "accountNumber": "string",
  "iban": "string"
}
```

---

### 2. Hesapları Listele

**GET** `/accounts`

**Requires:** Authorization header

#### Response
```json
{
  "success": true,
  "data": [
    {
      "id": "string",
      "bankName": "string",
      "accountNumber": "string",
      "iban": "string",
      "balance": 0,
      "currency": "TRY",
      "createdAt": "2025-01-15T10:30:00Z"
    }
  ]
}
```

---

## 💰 Transaction Endpoints (Gelecek için hazır)

### 1. Harcamaları Listele

**GET** `/transactions`

**Requires:** Authorization header

#### Query Parameters
- `startDate` (optional): ISO 8601 date
- `endDate` (optional): ISO 8601 date
- `category` (optional): string
- `limit` (optional): number
- `offset` (optional): number

---

## 📊 Budget Endpoints (Gelecek için hazır)

### 1. Bütçe Limiti Belirle

**POST** `/budget`

**Requires:** Authorization header

#### Request Body
```json
{
  "category": "string",
  "monthlyLimit": 0,
  "currency": "TRY"
}
```

---

## 🔔 Notification Endpoints (Gelecek için hazır)

### 1. Bildirimleri Al

**GET** `/notifications`

**Requires:** Authorization header

---

## ⚠️ Error Codes

| HTTP Code | Açıklama |
|-----------|----------|
| 200 | Başarılı |
| 201 | Oluşturuldu |
| 400 | Geçersiz istek |
| 401 | Yetkisiz erişim (Token geçersiz/eksik) |
| 403 | Yasaklı |
| 404 | Bulunamadı |
| 500 | Sunucu hatası |

---

## 🔒 Güvenlik

1. **HTTPS**: Tüm API çağrıları HTTPS üzerinden yapılmalıdır
2. **JWT Token**: Oturum yönetimi için JWT kullanılır
3. **Token Expiry**: Token'lar 24 saat sonra expire olur
4. **Rate Limiting**: Dakikada max 60 istek
5. **Password Hashing**: Şifreler bcrypt ile hash'lenir
6. **Security Answer**: Hash'lenerek saklanır

---

## 📝 Notlar

- Tüm tarihler ISO 8601 formatında olmalıdır
- Para birimi TRY, USD, EUR olabilir
- Tüm decimal değerler 2 basamaklı olmalıdır
- Request timeout: 30 saniye

---

## 🧪 Test Credentials

Development ortamı için test kullanıcısı:

```
Username: testuser
Password: Test123!
Security Answer: fluffy
```

---

Bu API endpoint'leri Node.js + Express + MongoDB ile implement edilmelidir.
