// Verilen para biriminin seçilen tarihteki TRY karşılığını veritabanından bulur

const FxRate = require("../models/FxRate");

async function getRateToTRY(currency, date = new Date()) {
  const c = String(currency || "TRY").toUpperCase();
  if (c === "TRY") return 1;

   
  const start = new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate(), 0, 0, 0));
  const end = new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate() + 1, 0, 0, 0));

  const row = await FxRate.findOne({
    currency: c,
    date: { $gte: start, $lt: end },
  }).lean();

  return row?.rateToTRY ?? null;
}

module.exports = { getRateToTRY };
