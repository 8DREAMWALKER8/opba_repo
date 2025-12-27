/** Bu dosya kullanıcının banka hesaplarıyla ilgili tüm işlemlerini yönetir.(listeleme, hesap ekleme, toplam bakiye hesaplama)
 * Tarihi UTC bazında gün başlangıcına çekmek için kullanılır.
 */

const router = require("express").Router();
const { z } = require("zod");
const { requireAuth } = require("../middleware/auth");
const BankAccount = require("../models/BankAccount");
const FxRate = require("../models/FxRate");


function startOfUTCDay(d) {
  return new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate(), 0, 0, 0));
}
function endOfUTCDay(d) {
  return new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate() + 1, 0, 0, 0));
}

async function getRateToTRY(currency, date = new Date()) {
  const c = String(currency || "TRY").toUpperCase();
  if (c === "TRY") return 1;

  const start = startOfUTCDay(date);
  const end = endOfUTCDay(date);

  const row = await FxRate.findOne({
    currency: c,
    date: { $gte: start, $lt: end },
  }).lean();

  return row?.rateToTRY ?? null;
}
// Hesap listeleme 
// Kullanıcıya ait tüm aktif banka hesaplarını listeler.
// Aynı zamanda her hesabın TRY karşılığı hesaplanır.

router.get("/", requireAuth, async (req, res) => {
  const accounts = await BankAccount.find({ userId: req.user.userId, isActive: true })
    .sort({ createdAt: -1 })
    .lean();

  const today = new Date();

  const accountsWithTRY = await Promise.all(
    accounts.map(async (acc) => {
      const currency = (acc.currency || "TRY").toUpperCase();
      const rateToTRY = await getRateToTRY(currency, today);
      const balanceTRY = rateToTRY == null ? null : Number(acc.balance || 0) * Number(rateToTRY);

      return {
        ...acc,
        rateToTRY,
        balanceTRY,
      };
    })
  );

  res.json({ ok: true, accounts: accountsWithTRY });
});

// Hesap ekleme 
// Frontend’den gelen hatalı veriler engellenir.
// Mock data mı, kullanıcı girişi mi ayrımı yapılır

router.post("/", requireAuth, async (req, res) => {
  const schema = z.object({
    bankName: z.string().min(2),
    accountName: z.string().min(2),
    iban: z.string().min(10),
    currency: z.enum(["TRY", "USD", "EUR"]).optional(),
    balance: z.number().optional(),
    source: z.enum(["manual", "mock"]).optional(),
  });

  const data = schema.parse(req.body);

  const account = await BankAccount.create({
    userId: req.user.userId,
    bankName: data.bankName,
    accountName: data.accountName,
    iban: data.iban,
    currency: data.currency || "TRY",
    balance: data.balance ?? 0,
    source: data.source || "manual",
    lastSyncedAt: null,
  });

  res.status(201).json({ ok: true, account });
});

// Toplam bakiye
// Ana sayfada gösterilecek toplam bakiye için kullanılır.
// Tüm hesaplar TRY'ye çevrilerek toplanır.

router.get("/total-balance", requireAuth, async (req, res) => {
  const accounts = await BankAccount.find({ userId: req.user.userId, isActive: true }).lean();
  const today = new Date();

  const converted = await Promise.all(
    accounts.map(async (a) => {
      const currency = (a.currency || "TRY").toUpperCase();
      const rateToTRY = await getRateToTRY(currency, today);
      const balanceTRY = rateToTRY == null ? null : Number(a.balance || 0) * Number(rateToTRY);
      return { ...a, rateToTRY, balanceTRY };
    })
  );

  const totalTRY = converted.reduce((sum, a) => sum + (a.balanceTRY || 0), 0);

  // GBP varsa ve sistemde kuru yoksa frontend uyarı verebilir.
  const missingRates = converted
    .filter((a) => a.rateToTRY == null)
    .map((a) => ({ _id: a._id, currency: a.currency, iban: a.iban }));

  res.json({
    ok: true,
    currency: "TRY",
    total: totalTRY,
    missingRates, 
  });
});

module.exports = router;
