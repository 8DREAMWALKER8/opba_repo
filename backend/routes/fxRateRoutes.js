const express = require("express");
const router = express.Router();
const FxRate = require("../models/FxRate");

// YYYY-MM-DD (UTC) -> [startUTC, endUTC)
function utcDayRange(dateStr) {
  const [y, m, d] = dateStr.split("-").map(Number);
  const start = new Date(Date.UTC(y, m - 1, d, 0, 0, 0, 0));
  const end = new Date(Date.UTC(y, m - 1, d + 1, 0, 0, 0, 0));
  return { start, end };
}

// Server saatine göre "bugün" yerine UTC "bugün" kullan
function todayUTCString() {
  const now = new Date();
  const y = now.getUTCFullYear();
  const m = String(now.getUTCMonth() + 1).padStart(2, "0");
  const d = String(now.getUTCDate()).padStart(2, "0");
  return `${y}-${m}-${d}`;
}

// GET /api/fx/today  -> bugünün (UTC) USD/EUR/TRY
router.get("/today", async (req, res) => {
  const dateStr = req.query.date || todayUTCString();
  const currency = req.query.currency; // 👈 EKLENDİ

  const { start, end } = utcDayRange(dateStr);

  const query = {
    date: { $gte: start, $lt: end },
  };

  if (currency) {
    query.currency = currency.toUpperCase();
  }

  const rows = await FxRate.find(query)
    .sort({ currency: 1 })
    .lean();

  if (currency && rows.length === 0) {
    return res.json({
      message: "Currency not found",
      currency,
    });
  }

  res.json(rows);
});

// GET /api/fx/latest -> en güncel tarihteki kur seti
router.get("/latest", async (req, res) => {
  const latest = await FxRate.findOne().sort({ date: -1 }).lean();
  if (!latest) return res.json([]);

  const { start, end } = utcDayRange(latest.date.toISOString().slice(0, 10));
  const rows = await FxRate.find({ date: { $gte: start, $lt: end } })
    .sort({ currency: 1 })
    .lean();

  res.json(rows);
});

module.exports = router;
