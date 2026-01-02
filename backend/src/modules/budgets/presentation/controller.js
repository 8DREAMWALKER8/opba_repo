console.log("BUDGET CONTROLLER LOADED");
const BudgetRepositoryMongo = require("../infrastructure/persistence/repositories/BudgetRepositoryMongo");
const GetBudgets = require("../application/usecases/GetBudgets");
const SetBudgetLimit = require("../application/usecases/SetBudgetLimit");

const budgetRepo = new BudgetRepositoryMongo();
const getBudgetsUC = new GetBudgets(budgetRepo);
const setBudgetLimitUC = new SetBudgetLimit(budgetRepo);

// GET /budgets
async function getBudgets(req, res) {
  try {
    const userId = req.user.userId;
    const budgets = await getBudgetsUC.execute({ userId });
    res.json({ ok: true, budgets });
  } catch (err) {
    console.error("getBudgets error:", err);
    res.status(500).json({ ok: false, message: err.message });
  }
}

// POST /budgets
async function setBudgetLimit(req, res) {
  try {
    const userId = req.user.userId;

    const budget = await setBudgetLimitUC.execute({
      userId,
      category: req.body.category,
      limit: req.body.limit,
      month: req.body.month,
      year: req.body.year,
      period: req.body.period,
    });

    res.json({ ok: true, budget });
  } catch (err) {
    console.error("setBudgetLimit error:", err);
    res.status(500).json({ ok: false, message: err.message });
  }
}

module.exports = {
  getBudgets,
  setBudgetLimit,
};
