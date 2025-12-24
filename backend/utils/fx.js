const FxRate = require("../models/FxRate");

/**
 * İstenen tarihte (varsayılan bugün) currency->TRY kurunu getirir.
 * TRY ise 1 döner.
 */
async function getRateToTRY(currency, date = new Date()) {
  const c = String(currency || "TRY").toUpperCase();
  if (c === "TRY") return 1;

  // Gün aralığı (UTC)
  const start = new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate(), 0, 0, 0));
  const end = new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate() + 1, 0, 0, 0));

  const row = await FxRate.findOne({
    currency: c,
    date: { $gte: start, $lt: end },
  }).lean();

  return row?.rateToTRY ?? null;
}

module.exports = { getRateToTRY };
