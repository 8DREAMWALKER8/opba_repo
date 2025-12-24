const mongoose = require("mongoose");

const TransactionSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true, index: true },
    accountId: { type: mongoose.Schema.Types.ObjectId, ref: "BankAccount", required: true, index: true },

    type: { type: String, enum: ["expense", "income"], required: true },
    amount: { type: Number, required: true },

    currency: { type: String, enum: ["TRY", "USD", "EUR"], default: "TRY" },
    category: {
      type: String,
      enum: ["market", "transport", "food", "bills", "entertainment", "health", "education", "other"],
      default: "other",
      index: true
    },

    description: { type: String, required: true, trim: true }, // Migros, Starbucks...
    occurredAt: { type: Date, required: true, index: true },

    source: { type: String, enum: ["manual", "mock", "bank"], default: "manual" }
  },
  { timestamps: true }
);

module.exports = mongoose.model("Transaction", TransactionSchema);
