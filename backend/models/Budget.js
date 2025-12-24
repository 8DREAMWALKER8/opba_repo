const mongoose = require("mongoose");

const BudgetSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true, index: true },

    // kategori key (market, food, bills...)
    category: {
      type: String,
      enum: ["market", "transport", "food", "bills", "entertainment", "health", "education", "other"],
      required: true,
      index: true,
    },

    // aylık limit
    limit: { type: Number, required: true, min: 0 },

    // şimdilik sadece monthly
    period: { type: String, enum: ["monthly"], default: "monthly" },

    month: { type: Number, required: true, min: 1, max: 12, index: true },
    year: { type: Number, required: true, min: 2000, max: 2100, index: true },
  },
  { timestamps: true }
);

// Aynı kullanıcı + aynı ay + aynı kategori tek kayıt olsun (upsert için ideal)
BudgetSchema.index({ userId: 1, category: 1, month: 1, year: 1 }, { unique: true });

module.exports = mongoose.model("Budget", BudgetSchema);
