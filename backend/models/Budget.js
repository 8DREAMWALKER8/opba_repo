/**
 * Bu model kullanıcıların aylık bütçelerini tutar.
 * Kategori bazlı aylık harcama limiti belirler.
 * Harcamalarla karşılaştırma yapar.
 */

const mongoose = require("mongoose");

const BudgetSchema = new mongoose.Schema(
  {
  // Bütçenin hangi kullanıcıya ait olduğunu belirtir.
  // Tüm sorgular userId üzerinden filtrelenir.
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true, index: true },

  // Bütçenin hangi harcama kategorisi için olduğunu belirtir.
  // Transaction modeliyle birebir aynı category key'leri kullanılır.
    category: {
      type: String,
      enum: ["market", "transport", "food", "bills", "entertainment", "health", "education", "other"],
      required: true,
      index: true,
    },

  // Bu kategori için aylık harcama limiti
  // 0 veya pozitif olmak zorunda
    limit: { type: Number, required: true, min: 0 },

    // Monthly destekleniyor.
    period: { type: String, enum: ["monthly"], default: "monthly" },

    month: { type: Number, required: true, min: 1, max: 12, index: true },
    year: { type: Number, required: true, min: 2000, max: 2100, index: true },
  },
  { timestamps: true }
);

// Aynı kullanıcı aynı ay ve aynı kategori için sadece 1 tane bütçe tanımı yapabilsin diye unique index kullanılıyor.
BudgetSchema.index({ userId: 1, category: 1, month: 1, year: 1 }, { unique: true });

module.exports = mongoose.model("Budget", BudgetSchema);
