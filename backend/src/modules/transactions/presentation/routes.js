const express = require("express");
const router = express.Router();

const { requireAuth } = require("../../../middleware/auth");

// === Repositories ===
const TransactionRepositoryMongo = require("../infrastructure/persistence/repositories/TransactionRepositoryMongo");
const BudgetRepositoryMongo = require("../../budgets/infrastructure/persistence/repositories/BudgetRepositoryMongo");
const NotificationRepositoryMongo = require("../../notifications/infrastructure/persistence/repositories/NotificationRepositoryMongo");

// === Usecases ===
const CreateTransaction = require("../application/usecases/CreateTransaction");
const GetMyTransactions = require("../application/usecases/GetMyTransactions");

// === Repo instances ===
const transactionRepo = new TransactionRepositoryMongo();
const budgetRepo = new BudgetRepositoryMongo();
const notificationRepo = new NotificationRepositoryMongo();

// === Usecase instances ===
const createTransaction = new CreateTransaction(
  transactionRepo,
  budgetRepo,
  notificationRepo
);

const getMyTransactions = new GetMyTransactions(transactionRepo);

// === Routes ===

// Transaction ekle
router.post("/", requireAuth, async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await createTransaction.execute({
      userId,
      amount: req.body.amount,
      category: req.body.category,
      description: req.body.description,
      type: req.body.type,
      currency: req.body.currency,
      occurredAt: req.body.occurredAt,
    });

    res.status(201).json({ ok: true, transaction: result });
  } catch (err) {
    console.error("CreateTransaction error:", err);
    res.status(500).json({
      ok: false,
      message: err.message,
    });
  }
});

// Transaction listele
router.get("/", requireAuth, async (req, res) => {
  try {
    const userId = req.user.userId;

    const items = await getMyTransactions.execute({
      userId,
      ...req.query,
    });

    res.json({ ok: true, transactions: items });
  } catch (err) {
    console.error("GetMyTransactions error:", err);
    res.status(500).json({
      ok: false,
      message: err.message,
    });
  }
});

module.exports = router;
