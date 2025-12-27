const mongoose = require("mongoose");

const FxRateSchema = new mongoose.Schema(
  {
    date: { type: Date, required: true, index: true }, // 00:00'a yuvarlanmış gün
    currency: { type: String, enum: ["TRY", "USD", "EUR"], required: true, index: true },
    rateToTRY: { type: Number, required: true },
    source: { type: String, default: "tcmb" },
  },
  { timestamps: true }
);

FxRateSchema.index({ date: 1, currency: 1 }, { unique: true });

module.exports = mongoose.model("FxRate", FxRateSchema);
