// TCMB’den alınan döviz kuru verilerinin MongoDB’de nasıl saklanacağını tanımlar.
// Tarih ve para birimi bazında unique index kullanılarak aynı gün için tekrar kayıt oluşması engellenir.

const mongoose = require("mongoose");

const FxRateSchema = new mongoose.Schema(
  {
    date: { type: Date, required: true, index: true },
    currency: { type: String, enum: ["TRY", "USD", "EUR", "GBP"], required: true, index: true },
    rateToTRY: { type: Number, required: true },
    source: { type: String, default: "tcmb" },
  },
  { timestamps: true }
);

FxRateSchema.index({ date: 1, currency: 1 }, { unique: true });

module.exports = mongoose.model("FxRate", FxRateSchema);
