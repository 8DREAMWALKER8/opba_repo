// Kullanıcıya ait tüm bilgiler burada tutulur.

const mongoose = require("mongoose");

const UserSchema = new mongoose.Schema(
  {
    // Kullanıcı adı
    username: { type: String, required: true, unique: true, trim: true },
    // Email
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    // Telefon numarası
    phone: { type: String, required: true, trim: true },
    // Hashlenmiş şifre
    passwordHash: { type: String, required: true },


    // Şifre sıfırlama için geçici alanlar
    resetCodeHash: { type: String, default: null },
    resetCodeExpiresAt: { type: Date, default: null },
    resetCodeAttempts: { type: Number, default: 0 },

    // Güvenlik sorusu bilgileri
    securityQuestionId: { type: String, required: true },
    securityAnswerHash: { type: String, required: true },

    // Kullanıcı ayarları
    language: { type: String, enum: ["tr", "en"], default: "tr" },
    currency: { type: String, enum: ["TRY", "USD", "EUR"], default: "TRY" },
    theme: { type: String, enum: ["light", "dark"], default: "light" },
  },
  { 
    timestamps: true }
);

module.exports = mongoose.model("User", UserSchema);
