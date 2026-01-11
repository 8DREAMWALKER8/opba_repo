/*
 kullanicilarin aylik butcelerini tutar.kategori baziı aylik harcama limiti belirler.
 harcamalarla karsılastirma yapar.
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

  // kategori icin aylik harcama limiti
    limit: { type: Number, required: true, min: 0 },

    period: { type: String, enum: ["monthly"], default: "monthly" },

    month: { type: Number, required: true, min: 1, max: 12, index: true },
    year: { type: Number, required: true, min: 2000, max: 2100, index: true },

    currency: { type: String, enum: ["TRY", "USD", "EUR", "GBP"], default: "TRY" },
  },
  { timestamps: true }
);

// unique index ile kullanici aynı ay ve kategori icin 1 tane tanimlasin
BudgetSchema.index({ userId: 1, category: 1, month: 1, year: 1 }, { unique: true });

module.exports = mongoose.model("Budget", BudgetSchema);
