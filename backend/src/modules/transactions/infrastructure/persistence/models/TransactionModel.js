const mongoose = require("mongoose");

const TransactionSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, required: true, index: true },
    amount: { type: Number, required: true },
    category: { type: String, required: true },
    description: { type: String, default: "" },
    type: { type: String, enum: ["expense", "income"], required: true },
    currency: { type: String, enum: ["TRY", "USD", "EUR"], default: "TRY" },
    occurredAt: { type: Date, default: Date.now, index: true },
  },
  { timestamps: true }
);

TransactionSchema.index({ userId: 1, occurredAt: -1 });

module.exports = mongoose.model("Transaction", TransactionSchema);
