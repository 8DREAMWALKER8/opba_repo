/**
 * Bu dosya, kullanıcıların gelir-gider işlemlerini yönetir:
 * İşlem listesi ekranı (filtreleme + arama + sayfalama)
 * Manuel gelir/gider ekleme ekranı
 * Harcama özeti ekranı (donut chart / kategori dağılımı)
 */

const router = require("express").Router();
const { z } = require("zod");
const mongoose = require("mongoose");

const { requireAuth } = require("../middleware/auth");
const Transaction = require("../models/Transaction");
const BankAccount = require("../models/BankAccount");

const Budget = require("../models/Budget");
const Notification = require("../models/Notification");

// Kategori label map (TR/EN)
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

// =====================
// GET /transactions
// İşlem Listeleme (Filtre + Arama + Sayfalama)
// =====================
router.get("/", requireAuth, async (req, res) => {
  try {
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
  } catch (err) {
    res.status(500).json({ ok: false, message: err.message });
  }
});

// =====================
// Helper: Bütçe limiti kontrol + bildirim
// =====================
async function checkBudgetLimitAndNotify({ userId, category, occurredAt }) {
  const cat = category || "other";

  const d = new Date(occurredAt || Date.now());
  const month = d.getMonth() + 1;
  const year = d.getFullYear();

  const budget = await Budget.findOne({ userId, category: cat, month, year });
  if (!budget) return;

  const start = new Date(year, month - 1, 1);
  const end = new Date(year, month, 1);

  const rows = await Transaction.aggregate([
    {
      $match: {
        userId: new mongoose.Types.ObjectId(userId),
        type: "expense",
        category: cat,
        occurredAt: { $gte: start, $lt: end },
      },
    },
    { $group: { _id: null, total: { $sum: "$amount" } } },
  ]);

  const total = rows[0]?.total || 0;

  if (total > budget.limit) {
    // Aynı ay/kategori için spam önleme (dedupeKey yoksa böyle kontrol)
    const exists = await Notification.findOne({
      userId,
      type: "limit_exceeded",
      createdAt: { $gte: start, $lt: end },
      body: { $regex: `\\b${cat}\\b`, $options: "i" },
    });

    if (exists) return;

    await Notification.create({
      userId,
      type: "limit_exceeded",
      title: "Bütçe limiti aşıldı",
      body: `${cat} kategorisinde bu ay toplam ${total} harcadın. Limitin: ${budget.limit}.`,
      isRead: false,
    });
  }
}

// =====================
// POST /transactions/manual
// Manuel işlem ekleme
// =====================
router.post("/manual", requireAuth, async (req, res) => {
  try {
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

    if (!acc) {
      return res.status(404).json({ ok: false, message: "Account not found" });
    }

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

    // Sadece expense için bütçe kontrol mantıklı
    if (tx.type === "expense") {
      await checkBudgetLimitAndNotify({
        userId: req.user.userId,
        category: tx.category,
        occurredAt: tx.occurredAt,
      });
    }

    return res.status(201).json({ ok: true, transaction: tx });
  } catch (err) {
    // Zod validation hatası
    if (err?.name === "ZodError") {
      return res.status(400).json({ ok: false, message: "Validation error", issues: err.issues });
    }
    return res.status(500).json({ ok: false, message: err.message });
  }
});

// =====================
// GET /transactions/spendings-summary
// Harcama Özeti (Donut Chart / Kategori Dağılımı)
// =====================
router.get("/spendings-summary", requireAuth, async (req, res) => {
  try {
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
      categoryKey: r._id,
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
  } catch (err) {
    if (err?.name === "ZodError") {
      return res.status(400).json({ ok: false, message: "Validation error", issues: err.issues });
    }
    res.status(500).json({ ok: false, message: err.message });
  }
});

module.exports = router;
