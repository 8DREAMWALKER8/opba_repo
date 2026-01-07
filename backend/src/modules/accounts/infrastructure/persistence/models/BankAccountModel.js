/**
 * Bu model kullanıcının banka hesaplarını temsil eder.
 * Her hesap bir kullanıcıya aittir ve bakiye bilgisi içerir.
 */
const mongoose = require("mongoose");

const BankAccountSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true, index: true },

    bankName: { type: String, required: true, trim: true }, // Banka adı
    accountName: { type: String, required: true, trim: true }, // Hesap türü
    iban: { type: String, required: true, trim: true }, // IBAN bilgisi

    currency: { type: String, enum: ["TRY", "USD", "EUR"], default: "TRY" }, // TRY, USD, EUR
    balance: { type: Number, default: 0 }, // Hesap bakiyesi

    isActive: { type: Boolean, default: true },
    lastSyncedAt: { type: Date, default: null },
    source: { type: String, enum: ["manual", "mock", "openbanking"], default: "manual" },
  },
  { timestamps: true }
);

// Aynı kullanıcı aynı IBAN’ı iki kere ekleyemez.
BankAccountSchema.index({ userId: 1, iban: 1 }, { unique: true });

module.exports = mongoose.model("BankAccount", BankAccountSchema);
