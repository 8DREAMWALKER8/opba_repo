/**
 * Bu dosya, kullanıcının aylık bütçe yönetimini yapar.
 * Kategori bazlı bütçe tanımlanır.
 * Ay içinde ne kadar harcandığını hesaplanır.
 * %80 uyarı ve %100 aşım durumları belirlenir.
 */
const router = require("express").Router();
const { z } = require("zod");
const mongoose = require("mongoose");
const { requireAuth } = require("../middleware/auth");
const Budget = require("../models/Budget");
const Transaction = require("../models/Transaction");

// Kategori label map (TR/EN)
// Kategoriler DB'de sabit key olarak tutulur (market, food vs.)
// Frontend'de dil seçimine göre (TR / EN) label gösterilir.
const categoryLabels = {
  tr: {
    market: "Market",
    transport: "Ulaşım",
    food: "Yemek",
    bills: "Faturalar",
    entertainment: "Eğlence",
    health: "Sağlık",
    education: "Eğitim",
    other: "Diğer",
  },
  en: {
    market: "Groceries",
    transport: "Transport",
    food: "Food",
    bills: "Bills",
    entertainment: "Entertainment",
    health: "Health",
    education: "Education",
    other: "Other",
  },
};

function getMonthRange(year, month) {
  
  const start = new Date(Date.UTC(year, month - 1, 1, 0, 0, 0, 0));
  const end = new Date(Date.UTC(year, month, 0, 23, 59, 59, 999)); 
  return { start, end };
}

// 1) Bütçe oluşturma / güncelleme (upsert) 
// POST /budgets
// Aynı ay + kategori için tekrar çağrılırsa günceller (upsert).
// Yoksa yeni bütçe oluşturur.
router.post("/", requireAuth, async (req, res) => {
  const schema = z.object({
    category: z.enum([
      "market",
      "transport",
      "food",
      "bills",
      "entertainment",
      "health",
      "education",
      "other",
    ]),
    limit: z.number().min(0),
    
    month: z.number().min(1).max(12).optional(),
    year: z.number().min(2000).max(2100).optional(),
    period: z.literal("monthly").optional(),
  });

  const data = schema.parse(req.body);

  const now = new Date();
  const month = data.month || now.getMonth() + 1;
  const year = data.year || now.getFullYear();

  const userId = new mongoose.Types.ObjectId(req.user.userId);

  const doc = await Budget.findOneAndUpdate(
    { userId, category: data.category, month, year },
    { $set: { limit: data.limit, period: "monthly", month, year } },
    { upsert: true, new: true }
  );

  res.status(201).json({ ok: true, budget: doc });
});

// 2) Bütçeleri listeleme
// GET /budgets
// Seçilen ay ve yıla ait tüm bütçeleri listeler.
router.get("/", requireAuth, async (req, res) => {
  const schema = z.object({
    month: z.string().optional(),
    year: z.string().optional(),
    lang: z.enum(["tr", "en"]).optional(),
  });

  const { month, year, lang } = schema.parse(req.query);
  const locale = lang || "tr";

  const now = new Date();
  const m = month ? parseInt(month, 10) : now.getMonth() + 1;
  const y = year ? parseInt(year, 10) : now.getFullYear();

  const userId = new mongoose.Types.ObjectId(req.user.userId);

  const items = await Budget.find({ userId, month: m, year: y }).sort({ category: 1 });

  res.json({
    ok: true,
    lang: locale,
    month: m,
    year: y,
    items: items.map((b) => ({
      id: b._id,
      categoryKey: b.category,
      label: categoryLabels[locale]?.[b.category] || b.category,
      limit: b.limit,
      period: b.period,
      createdAt: b.createdAt,
      updatedAt: b.updatedAt,
    })),
  });
});

// 3) Bütçe progress
// Bütçe - harcama karşılaştırmasını yapar.
router.get("/progress", requireAuth, async (req, res) => {
  const schema = z.object({
    month: z.string().optional(),
    year: z.string().optional(),
    lang: z.enum(["tr", "en"]).optional(),
  });

  const { month, year, lang } = schema.parse(req.query);
  const locale = lang || "tr";

  const now = new Date();
  const m = month ? parseInt(month, 10) : now.getMonth() + 1;
  const y = year ? parseInt(year, 10) : now.getFullYear();

  const userId = new mongoose.Types.ObjectId(req.user.userId);
  const { start, end } = getMonthRange(y, m);

  // Bu ayın bütçeleri
  const budgets = await Budget.find({ userId, month: m, year: y });

  // Bu ayın harcamalarını kategori bazlı toplama
  const spendRows = await Transaction.aggregate([
    {
      $match: {
        userId,
        type: "expense",
        occurredAt: { $gte: start, $lte: end },
      },
    },
    {
      $group: {
        _id: { $ifNull: ["$category", "other"] },
        spent: { $sum: "$amount" },
      },
    },
  ]);

  const spentMap = new Map(spendRows.map((r) => [r._id, r.spent]));

  const items = budgets.map((b) => {
    const spent = Math.round(((spentMap.get(b.category) || 0) * 100)) / 100;
    const limit = b.limit;
    const remaining = Math.round(((limit - spent) * 100)) / 100;
    const percentUsed = limit > 0 ? Math.round((spent / limit) * 1000) / 10 : 0;

    let status = "ok";
    if (limit > 0 && percentUsed >= 100) status = "exceeded";
    else if (limit > 0 && percentUsed >= 80) status = "warn";

    return {
      categoryKey: b.category,
      label: categoryLabels[locale]?.[b.category] || b.category,
      month: m,
      year: y,
      limit,
      spent,
      remaining,
      percentUsed,
      status, 
    };
  });

  res.json({ ok: true, lang: locale, month: m, year: y, items });
});

module.exports = router;
