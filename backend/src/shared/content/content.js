// uygulama genelinde kullanılan Türkçe / İngilizce metinleri ve hata mesajlarını içerir.

module.exports = {
  tr: {
    errors: {
      // Generic
      VALIDATION_ERROR: "Doğrulama hatası.",
      INTERNAL_SERVER_ERROR: "Sunucu hatası.",

      // Auth / Token
      AUTH_TOKEN_MISSING: "Token bulunamadı.",
      AUTH_TOKEN_INVALID: "Token geçersiz.",
      AUTH_FORBIDDEN: "Bu işlem için yetkin yok.",

      // Users / Login
      USER_NOT_FOUND: "Kullanıcı bulunamadı.",
      INVALID_CREDENTIALS: "E-posta veya şifre hatalı.",
      EMAIL_EXISTS: "Bu e-posta zaten kayıtlı.",
      USERNAME_EXISTS: "Bu kullanıcı adı zaten kayıtlı.",
      SECURITY_ANSWER_INVALID: "Güvenlik sorusu cevabı hatalı.",

      // Register
      PASSWORD_CONFIRM_MISMATCH:"Şifreler aynı değil.",
      PASSWORD_CONFIRM_REQUIRED: "Şifre tekrarı zorunludur.",
    
      // Password reset
      RESET_SENT: "Doğrulama kodu gönderildi.",
      RESET_USER_NOT_FOUND: "Bu e-postaya ait kullanıcı bulunamadı.",
      RESET_INVALID_CODE: "Kod geçersiz.",
      RESET_CODE_EXPIRED: "Kodun süresi dolmuş.",
      RESET_PASSWORD_MISMATCH: "Şifreler eşleşmiyor.",
      RESET_TOKEN_INVALID: "Reset token geçersiz veya süresi dolmuş.",
      RESET_SAME_AS_OLD: "Yeni şifre mevcut şifreyle aynı olamaz.",
      PASSWORD_WEAK:
        "Şifre en az 8 karakter olmalı; büyük harf, küçük harf ve özel karakter içermelidir.",
      RESET_TOO_MANY_ATTEMPTS: "Çok fazla deneme yapıldı. Lütfen tekrar deneyin.",
      JWT_SECRET_MISSING: "JWT_SECRET eksik. .env dosyanı kontrol et.",
      PASSWORD_UPDATED: "Şifre başarıyla güncellendi.",

      // DB conflicts
      IBAN_EXISTS: "Bu IBAN zaten ekli.",

      // Loan / Interest
      BANK_NAME_REQUIRED: "bank_name zorunludur.",
      TERM_MONTHS_INVALID: "term_months geçersiz.",
      PRINCIPAL_INVALID: "principal geçersiz.",
      RATE_NOT_FOUND: "Bu filtrelerle oran bulunamadı.",
      MONTHLY_RATE_PARSE_ERROR: "monthly_rate ayrıştırılamadı.",
      CALC_ERROR: "Hesaplama hatası.",
      INTEREST_RATES_ERROR: "Faiz oranları hatası.",
      TERMS_NOT_FOUND: "Vade bilgisi bulunamadı.",
      TERMS_ERROR: "Vade bilgisi hatası.",

      // Domain
      USER_ID_REQUIRED: "userId zorunludur.",
      AMOUNT_INVALID: "amount pozitif bir sayı olmalıdır.",
      CATEGORY_REQUIRED: "category zorunludur.",
      TYPE_INVALID: "type geçersiz (expense/income olmalı).",
      PHONE_INVALID: "Telefon numarası geçersiz.",
      PHONE_INVALID_FORMAT: "Telefon numarası sadece rakam olmalı (10-15).",
      DATA_REQUIRED: "Güncellenecek veri zorunludur.",
      LIMIT_IS_REQUİRED: "Limit zorunludur.",
      MONTH_IS_REQUIRED: "Ay girmek zorunludur.",
      YEAR_IS_REQUIRED: "Yıl girmek zorunludur.",

      // Accounts 
      BANK_NAME_REQUIRED: "Banka adı zorunludur.",
      BANK_NAME_INVALID: "Geçersiz banka adı.",
      ACCOUNT_NAME_REQUIRED: "Hesap adı zorunludur.",
      IBAN_REQUIRED: "IBAN zorunludur.",
      IBAN_INVALID_FORMAT: "IBAN formatı geçersiz.",
      BALANCE_INVALID: "Bakiye 0 veya pozitif bir sayı olmalıdır.",
      ACCOUNT_DUPLICATE_IBAN: "Bu IBAN zaten ekli.",
      DUPLICATE_KEY: "Bu değer zaten kullanılıyor.",
      ACCOUNT_NOT_FOUND: "Hesap bulunamadı.",
      NOTIFICATION_NOT_FOUND: "Bildirim bulunamadı.",

      // FXRATE
      NOT_IMPLEMENTED: "Uygulanamadı.",

      // BUDGET
      NO_BUDGET: "Bu kategori için tanımlı bir bütçe bulunmuyor.",
      INVALID_LIMIT: "Bütçe limiti geçersiz."
    },

    enums: {
      currency: {
        TRY: "Türk Lirası (₺)",
        USD: "Amerikan Doları ($)",
        EUR: "Euro (€)",
      },
      transactionType: {
        expense: "Gider",
        income: "Gelir",
      },
      category: {
        market: "Market",
        transport: "Ulaşım",
        food: "Yeme-İçme",
        bills: "Faturalar",
        entertainment: "Eğlence",
        health: "Sağlık",
        education: "Eğitim",
        other: "Diğer",
      },
    },
  },

  en: {
    errors: {
      // Generic
      VALIDATION_ERROR: "Validation error.",
      INTERNAL_SERVER_ERROR: "Internal Server Error.",

      // Auth / Token
      AUTH_TOKEN_MISSING: "Token is missing.",
      AUTH_TOKEN_INVALID: "Invalid token.",
      AUTH_FORBIDDEN: "You do not have permission.",

      // Users / Login
      USER_NOT_FOUND: "User not found.",
      INVALID_CREDENTIALS: "Invalid email or password.",
      EMAIL_EXISTS: "This email is already registered.",
      USERNAME_EXISTS: "This username is already taken.",
      SECURITY_ANSWER_INVALID: "Security answer is incorrect.",

      // Register
      PASSWORD_CONFIRM_MISMATCH:"Passwords do not match.",
      PASSWORD_CONFIRM_REQUIRED:"Password confirmation is required.",
      // Password reset
      RESET_SENT: "Verification code sent.",
      RESET_USER_NOT_FOUND: "No user found with this email.",
      RESET_INVALID_CODE: "Invalid code.",
      RESET_CODE_EXPIRED: "Code expired.",
      RESET_PASSWORD_MISMATCH: "Passwords do not match.",
      RESET_TOKEN_INVALID: "Reset token is invalid or expired.",
      RESET_SAME_AS_OLD: "New password must be different from the current password.",
      PASSWORD_WEAK:
        "Password must be at least 8 characters and include at least 1 uppercase letter, 1 lowercase letter, and 1 special character.",
      RESET_TOO_MANY_ATTEMPTS: "Too many attempts. Please try again later.",
      JWT_SECRET_MISSING: "JWT_SECRET is missing. Check your .env file.",
      PASSWORD_UPDATED: "Password updated successfully.",

      // DB conflicts
      IBAN_EXISTS: "This IBAN already exists.",

      // Loan / Interest
      BANK_NAME_REQUIRED: "bank_name is required.",
      TERM_MONTHS_INVALID: "term_months is invalid.",
      PRINCIPAL_INVALID: "principal is invalid.",
      RATE_NOT_FOUND: "Rate not found for given filters.",
      MONTHLY_RATE_PARSE_ERROR: "monthly_rate parse error.",
      CALC_ERROR: "Calculation error.",
      INTEREST_RATES_ERROR: "Interest rates error.",
      TERMS_NOT_FOUND: "No terms found.",
      TERMS_ERROR: "Terms error.",

      // Domain
      USER_ID_REQUIRED: "userId is required.",
      AMOUNT_INVALID: "amount must be a positive number.",
      CATEGORY_REQUIRED: "category is required.",
      TYPE_INVALID: "type must be 'expense' or 'income'.",
      PHONE_INVALID: "Invalid phone number.",
      PHONE_INVALID_FORMAT: "Phone must be digits only (10-15).",
      DATA_REQUIRED: "data is required.",
      LIMIT_IS_REQUIRED: "Limit is required.",
      MONTH_IS_REQUIRED: "month is required",
      YEAR_IS_REQUIRED: "Year is required.",

      // Accounts
      BANK_NAME_REQUIRED: "Bank name is required.",
      BANK_NAME_INVALID: "Invalid bank name.",
      ACCOUNT_NAME_REQUIRED: "Account name is required.",
      IBAN_REQUIRED: "IBAN is required.",
      IBAN_INVALID_FORMAT: "Invalid IBAN format.",
      BALANCE_INVALID: "Balance must be zero or a positive number.",
      ACCOUNT_DUPLICATE_IBAN: "This IBAN is already added.",
      DUPLICATE_KEY: "This value is already in use.",
      ACCOUNT_NOT_FOUND: "Account not found.",
      NOTIFICATION_NOT_FOUND: "Notification not found",

      // FXRATE
      NOT_IMPLEMENTED: "Not implemented",

      // BUDGET
      NO_BUDGET: "No budget defined for this category.",
      INVALID_LIMIT: "Budget limit is invalid."
    },

    enums: {
      currency: {
        TRY: "Turkish Lira (₺)",
        USD: "US Dollar ($)",
        EUR: "Euro (€)",
      },
      transactionType: {
        expense: "Expense",
        income: "Income",
      },
      category: {
        market: "Market",
        transport: "Transport",
        food: "Food & Drink",
        bills: "Bills",
        entertainment: "Entertainment",
        health: "Health",
        education: "Education",
        other: "Other",
      },
    },
  },
};
