const { t } = require("../../../shared/content");

function makeBudgetsController({ getBudgetsUC, setBudgetLimitUC, deleteBudgetUC }) {
  return {
    // GET /budgets?month=1&year=2026 (opsiyonel)
    getBudgets: async (req, res) => {
      const userId = req.user?.userId || req.user?.id || req.user?._id;
      if (!userId) {
        return res.status(401).json({ ok: false, code: "UNAUTHORIZED" });
      }

      // month/year query’den alınır (opsiyonel)
      const month = req.query.month !== undefined ? Number(req.query.month) : undefined;
      const year = req.query.year !== undefined ? Number(req.query.year) : undefined;
      const currency = req.query.currency;

      // NaN koruması
      const safeMonth = Number.isFinite(month) ? month : undefined;
      const safeYear = Number.isFinite(year) ? year : undefined;

      const budgets = await getBudgetsUC.execute({
        userId,
        month: safeMonth,
        year: safeYear,
        currency: currency,
      });

      return res.json({ ok: true, budgets });
    },

    // POST /budgets
    // body: { category, limitAmount, month, year, currency? }
    setBudgetLimit: async (req, res) => {
      const userId = req.user?.userId || req.user?.id || req.user?._id;
      if (!userId) {
        return res.status(401).json({ ok: false, code: "UNAUTHORIZED" });
      }

      const category = req.body.category;
      const month = req.body.month !== undefined ? Number(req.body.month) : undefined;
      const year = req.body.year !== undefined ? Number(req.body.year) : undefined;

      // Frontend bazen limit, bazen limitAmount göndermiş olabilir.
      // Backend standardı: limitAmount
      const limitAmountRaw = req.body.limitAmount ?? req.body.limit;
      const limitAmount = limitAmountRaw !== undefined ? Number(limitAmountRaw) : undefined;
console.log(limitAmount);
      const currency = req.body.currency; // opsiyonel (TRY vs)

      try {
        const budget = await setBudgetLimitUC.execute({
          userId,
          category,
          limit: limitAmount,
          month,
          year,
          currency,
        });

        return res.status(201).json({ ok: true, budget });
      } catch (err) {
        // err.statusCode varsa usecase’ten geliyor olabilir
        const status = err.statusCode || 400;
        const code = err.message || "BUDGET_ERROR";

        return res.status(status).json({
          ok: false,
          code,
          message: t(req, `errors.${code}`, code),
        });
      }
    },

    deleteBudget: async (req, res) => {
      try {
        const userId = req.user?.userId || req.user?.id || req.user?._id;
        const budgetId = req.params.id;

        const deleted = await deleteBudgetUC.execute({ userId, budgetId });
        return res.json({ ok: true, budget: deleted });
      } catch (err) {
        return res.status(err.statusCode || 400).json({
          ok: false,
          code: err.message,
          message: t(req, `errors.${err.message}`, err.message),
        });
      }
    },
  };
}

module.exports = makeBudgetsController;