/*
 Bu dosya banka hesabının veritabanındaki karşılığını tanımlar.  
 MongoDB’de BankAccount koleksiyonunun şemasıdır.
 */
const mongoose = require("mongoose");

const BankAccountSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },

    bankName: { type: String, required: true, trim: true },
    cardHolderName: { type: String, required: true, trim: true },
    cardNumber: { type: String, required: true, trim: true },

    currency: { type: String, enum: ["TRY", "USD", "EUR", "GBP"], default: "TRY" },
    balance: { type: Number, default: 0 },
    isActive: { type: Boolean, default: true },
    lastSyncedAt: { type: Date, default: null },
    source: { type: String, enum: ["manual", "mock", "openbanking"], default: "manual" },
    description: { type: String, default: "" },
  },
  { timestamps: true }
);

BankAccountSchema.index({ userId: 1, cardNumber: 1 }, { unique: true });

module.exports = mongoose.model("BankAccount", BankAccountSchema);