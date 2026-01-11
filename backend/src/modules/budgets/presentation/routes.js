const express = require("express");
const router = express.Router();

const { requireAuth } = require("../../../middleware/auth");

// repos
const BudgetRepositoryMongo = require("../infrastructure/persistence/repositories/BudgetRepositoryMongo");
const TransactionRepositoryMongo = require("../../transactions/infrastructure/persistence/repositories/TransactionRepositoryMongo");

// usecases
const GetBudgets = require("../application/usecases/GetBudgets");
const SetBudgetLimit = require("../application/usecases/SetBudgetLimit");
const DeleteBudget = require("../application/usecases/DeleteBudget");

// controller factory
const makeBudgetsController = require("./controller");
const FxRateRepositoryMongo = require("../../fxrates/infrastructure/persistence/repositories/FxRateRepositoryMongo");

// wiring
const budgetRepo = new BudgetRepositoryMongo();
const txRepo = new TransactionRepositoryMongo();
const fxRepo = new FxRateRepositoryMongo();

const getBudgetsUC = new GetBudgets({ budgetRepo, txRepo, fxRepo });
const setBudgetLimitUC = new SetBudgetLimit(budgetRepo);
const deleteBudgetUC = new DeleteBudget({ budgetRepo });

const controller = makeBudgetsController({ getBudgetsUC, setBudgetLimitUC, deleteBudgetUC });

router.get("/", requireAuth, controller.getBudgets);
router.post("/", requireAuth, controller.setBudgetLimit);
router.delete("/:id", requireAuth, controller.deleteBudget);

module.exports = router;