/**
 * Transaction modeli kullanıcının tüm finansal işlemlerini tutar.
 * Gelir ve giderler bu tablo üzerinden yönetilir.
 */
const mongoose = require("mongoose");

const TransactionSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true, index: true }, // işlemi yapan kullanıcı
    accountId: { type: mongoose.Schema.Types.ObjectId, ref: "BankAccount", required: true, index: true }, // işlemin bağlı olduğu banka hesabı

    type: { type: String, enum: ["expense", "income"], required: true },
    amount: { type: Number, required: true },

    currency: { type: String, enum: ["TRY", "USD", "EUR"], default: "TRY" },
    category: {
      type: String,
      enum: ["market", "transport", "food", "bills", "entertainment", "health", "education", "other"],
      default: "other",
      index: true
    },

    description: { type: String, required: true, trim: true }, 
    occurredAt: { type: Date, required: true, index: true },

    source: { type: String, enum: ["manual", "mock", "bank"], default: "manual" }
  },
  { timestamps: true }
);

module.exports = mongoose.model("Transaction", TransactionSchema);
