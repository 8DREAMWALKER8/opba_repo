const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    // Ad Soyad
    name: {
      type: String,
      required: true,
      trim: true,
    },

    // Kullanıcı adı (benzersiz)
    username: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },

    // E-posta (benzersiz)
    email: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true,
    },

    // Telefon
    phone: {
      type: String,
      required: true,
      trim: true,
    },

    address: {
      type: String,
      required: false, // Ekranda "isteğe bağlı" olduğu için
    },

    // Hash'lenmiş şifre
    password: {
      type: String,
      required: true,
      minlength: 6,
    },

    // Güvenlik sorusu (metni)
    securityQuestion: {
      type: String,
      required: true,
    },

    // Güvenlik sorusunun hash'lenmiş cevabı
    securityAnswer: {
      type: String,
      required: true,
    },

        // Uygulama dil tercihi
    language: {
      type: String,
      enum: ["tr", "en"],
      default: "tr", // varsayılan Türkçe
    },

        // Varsayılan para birimi (TRY, USD, EUR)
    currency: {
      type: String,
      enum: ["TRY", "USD", "EUR"],
      default: "TRY",
    },

    // 6 haneli şifre sıfırlama kodu (hash'li)
    resetPasswordCode: String,

    // Kodun son geçerlilik zamanı
    resetPasswordCodeExpire: Date,
  },
  { timestamps: true }
);

module.exports = mongoose.model("User", userSchema);
