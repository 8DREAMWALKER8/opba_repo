const BudgetRepositoryMongo = require("../infrastructure/persistence/repositories/BudgetRepositoryMongo");
const GetBudgets = require("../application/usecases/GetBudgets");
const SetBudgetLimit = require("../application/usecases/SetBudgetLimit");

const { t } = require("../../../shared/content"); //dil secenegi

const budgetRepo = new BudgetRepositoryMongo();

// repo bagı
const getBudgetsUC = new GetBudgets(budgetRepo);
const setBudgetLimitUC = new SetBudgetLimit(budgetRepo);

// get kullanici bilgilerini alir http response
async function getBudgets(req, res) {
  try {
    const userId = req.user?.userId || req.user?.id || req.user?._id;

    const budgets = await getBudgetsUC.execute({ userId });
    return res.json({ ok: true, budgets });
  } catch (err) {
    console.error("getBudgets error:", err);

    // usecase heta verirse repodaki fonlsiyonu calistir
    try {
      const userId = req.user?.userId || req.user?.id || req.user?._id;

      const fn =
        budgetRepo.findByUser ||
        budgetRepo.findByUserId ||
        budgetRepo.getByUser ||
        budgetRepo.listByUser;

      if (typeof fn === "function") {
        const budgets = await fn.call(budgetRepo, userId);
        return res.json({ ok: true, budgets });
      }
    } catch (e2) {
      console.error("getBudgets fallback error:", e2);
    }

    return res.status(500).json({ ok: false, message: err.message });
  }
}

// kullanicidan alır db'ye kaydeder
async function setBudgetLimit(req, res) {
  try {
    const userId = req.user?.userId || req.user?.id || req.user?._id;

    const budget = await setBudgetLimitUC.execute({ //usecase
      userId,
      category: req.body.category,
      limit: req.body.limit,
      month: req.body.month,
      year: req.body.year,
      period: req.body.period,
    });

    return res.json({ ok: true, budget });
  } catch (err) {
    console.error("setBudgetLimit error:", err);
     return res.status(err.statusCode || 400).json({
      ok: false,
      code: err.message,
      message: t(req, `errors.${err.message}`, err.message),
   });
  }
}

module.exports = {
  getBudgets,
  setBudgetLimit,
};
