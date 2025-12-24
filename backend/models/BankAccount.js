const mongoose = require("mongoose");

const BankAccountSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true, index: true },

    bankName: { type: String, required: true, trim: true },   // örn: Ziraat, Garanti
    accountName: { type: String, required: true, trim: true },// örn: Vadesiz TL
    iban: { type: String, required: true, trim: true },

    currency: { type: String, enum: ["TRY", "USD", "EUR"], default: "TRY" },
    balance: { type: Number, default: 0 },

    isActive: { type: Boolean, default: true },
    lastSyncedAt: { type: Date, default: null }, // open banking yoksa null kalır
    source: { type: String, enum: ["manual", "mock", "openbanking"], default: "manual" },
  },
  { timestamps: true }
);

// Aynı kullanıcı aynı IBAN'ı iki kere eklemesin
BankAccountSchema.index({ userId: 1, iban: 1 }, { unique: true });

module.exports = mongoose.model("BankAccount", BankAccountSchema);
