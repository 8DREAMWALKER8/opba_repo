 /** 
 * Bu dosya, kullanıcıların gelir-gider işlemlerini yönetir:
 * İşlem listesi ekranı (filtreleme + arama + sayfalama)
 * Manuel gelir/gider ekleme ekranı
 *nHarcama özeti ekranı (donut chart / kategori dağılımı)
*/
const router = require("express").Router();
const { z } = require("zod");
const mongoose = require("mongoose");
const { requireAuth } = require("../middleware/auth");
const Transaction = require("../models/Transaction");
const BankAccount = require("../models/BankAccount");

// Kategori label map (TR/EN)
// Kategori anahtarlarını kullanıcıya diline göre gösterilebilir label'a çeviriyoruz. DB tarafında key sabit kalıyor, UI tarafında label değişiyor.
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

// İşlem Listeleme (Filtre + Arama + Sayfalama)
// GET /transactions. Bu endpoint işlem listesi ekranını doldurur.
//  Query parametreleri ile filtreleme yapıyoruz.
router.get("/", requireAuth, async (req, res) => {
  const {
    accountId,
    type,
    category,
    from,
    to,
    min,
    max,
    q,
    page = "1",
    limit = "20",
  } = req.query;

  const filter = { userId: req.user.userId };

  if (accountId) filter.accountId = accountId;
  if (type) filter.type = type;
  if (category) filter.category = category;

// Tarih filtresi
  if (from || to) {
    filter.occurredAt = {};
    if (from) filter.occurredAt.$gte = new Date(from);
    if (to) filter.occurredAt.$lte = new Date(to);
  }
// Tutar filtresi
  if (min || max) {
    filter.amount = {};
    if (min) filter.amount.$gte = Number(min);
    if (max) filter.amount.$lte = Number(max);
  }

  if (q) filter.description = { $regex: q, $options: "i" };

  const pageNum = Math.max(1, parseInt(page, 10) || 1);
  const limitNum = Math.min(100, Math.max(1, parseInt(limit, 10) || 20));
  const skip = (pageNum - 1) * limitNum;

  const [items, total] = await Promise.all([
    Transaction.find(filter).sort({ occurredAt: -1 }).skip(skip).limit(limitNum),
    Transaction.countDocuments(filter),
  ]);

  res.json({ ok: true, page: pageNum, limit: limitNum, total, items });
});

// Manuel işlem ekleme
// POST /transactions/manual. Kullanıcı manuel gelir/gider eklediğinde burası çalışır. 
router.post("/manual", requireAuth, async (req, res) => {
  const schema = z.object({
    accountId: z.string().min(1),
    type: z.enum(["expense", "income"]),
    amount: z.number().positive(),
    currency: z.enum(["TRY", "USD", "EUR"]).optional(),
    category: z
      .enum([
        "market",
        "transport",
        "food",
        "bills",
        "entertainment",
        "health",
        "education",
        "other",
      ])
      .optional(),
    description: z.string().min(2),
    occurredAt: z.string().min(1),
  });

  const data = schema.parse(req.body);
  // Account kontrolü
  const acc = await BankAccount.findOne({
    _id: data.accountId,
    userId: req.user.userId,
    isActive: true,
  });
  if (!acc) return res.status(404).json({ ok: false, message: "Account not found" });

  const tx = await Transaction.create({
    userId: req.user.userId,
    accountId: data.accountId,
    type: data.type,
    amount: data.amount,
    currency: data.currency || acc.currency || "TRY",
    category: data.category || "other",
    description: data.description,
    occurredAt: new Date(data.occurredAt),
    source: "manual",
  });

  res.status(201).json({ ok: true, transaction: tx });
});

// Harcama Özeti (Donut Chart / Kategori Dağılımı)
// GET /transactions/spendings-summary. Harcamalar ekranındaki donut grafiği için.
router.get("/spendings-summary", requireAuth, async (req, res) => {
  const schema = z.object({
    from: z.string().optional(),
    to: z.string().optional(),
    accountId: z.string().optional(),
    top: z.string().optional(),
    lang: z.enum(["tr", "en"]).optional(),
  });

  const { from, to, accountId, top, lang } = schema.parse(req.query);
  const locale = lang || "tr";
  const topN = Math.min(parseInt(top || "10", 10) || 10, 50);

  const match = {
    userId: new mongoose.Types.ObjectId(req.user.userId),
    type: "expense",
  };
// accountId ile filtre istenirse eklenir
  if (accountId) match.accountId = new mongoose.Types.ObjectId(accountId);

  if (from || to) {
    match.occurredAt = {};
    if (from) match.occurredAt.$gte = new Date(from);
    if (to) {
      const end = new Date(to);
      end.setHours(23, 59, 59, 999);
      match.occurredAt.$lte = end;
    }
  }
  // MongoDB aggregate:
  // 1) match -> filtre
  // 2) group -> category bazlı toplama
  // 3) sort -> en çok harcanan üstte
  const rows = await Transaction.aggregate([
    { $match: match },
    {
      $group: {
        _id: { $ifNull: ["$category", "other"] },
        amount: { $sum: "$amount" },
      },
    },
    { $sort: { amount: -1 } },
  ]);

  const totalSpending = rows.reduce((sum, r) => sum + r.amount, 0);

  let byCategory = rows.map((r) => ({
    categoryKey: r._id, // key
    label: categoryLabels[locale]?.[r._id] || r._id, 
    amount: Math.round(r.amount * 100) / 100,
  }));

  if (byCategory.length > topN) {
    const head = byCategory.slice(0, topN);
    const tail = byCategory.slice(topN);
    const otherAmount = tail.reduce((sum, x) => sum + x.amount, 0);
    byCategory = [
      ...head,
      { categoryKey: "other", label: categoryLabels[locale].other, amount: otherAmount },
    ];
  }

  byCategory = byCategory.map((x) => ({
    ...x,
    percent: totalSpending ? Math.round((x.amount / totalSpending) * 1000) / 10 : 0,
  }));

  res.json({
    ok: true,
    currency: "TRY",
    lang: locale,
    range: { from: from || null, to: to || null },
    totalSpending: Math.round(totalSpending * 100) / 100,
    byCategory,
  });
});

module.exports = router;
