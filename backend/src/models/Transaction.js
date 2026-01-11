const mongoose = require("mongoose");

const TYPES = ["expense", "income"];
const CURRENCIES = ["TRY", "USD", "EUR", "GBP"];
const CATEGORIES = ["market", "transport", "food", "bills", "entertainment", "health", "education", "other"];
const SOURCES = ["manual", "mock", "bank"];

const TransactionSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },

    accountId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "BankAccount",
      required: true,
      index: true,
    },

    type: { type: String, enum: TYPES, required: true },

    amount: { type: Number, required: true },

    currency: { type: String, enum: CURRENCIES, default: "TRY" },

    category: {
      type: String,
      enum: CATEGORIES,
      default: "other",
      index: true,
    },

    description: { type: String, required: true, trim: true },

    occurredAt: { type: Date, required: true, index: true },

    source: { type: String, enum: SOURCES, default: "manual" },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Transaction", TransactionSchema);
