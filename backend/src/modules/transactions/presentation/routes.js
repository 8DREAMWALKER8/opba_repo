const express = require("express");
const router = express.Router();

const { requireAuth } = require("../../../middleware/auth");

// === Repositories ===
const TransactionRepositoryMongo = require("../infrastructure/persistence/repositories/TransactionRepositoryMongo");
const BudgetRepositoryMongo = require("../../budgets/infrastructure/persistence/repositories/BudgetRepositoryMongo");
const NotificationRepositoryMongo = require("../../notifications/infrastructure/persistence/repositories/NotificationRepositoryMongo");
const BankAccountRepositoryMongo = require("../../accounts/infrastructure/persistence/repositories/BankAccountRepositoryMongo");

// === Usecases ===
const CreateTransaction = require("../application/usecases/CreateTransaction");
const GetMyTransactions = require("../application/usecases/GetMyTransactions");
const PatchTransaction = require("../application/usecases/PatchTransaction");
const DeleteTransaction = require("../application/usecases/DeleteTransaction");

// === Repo instances ===
const transactionRepo = new TransactionRepositoryMongo();
const accountRepo = new BankAccountRepositoryMongo();
const budgetRepo = new BudgetRepositoryMongo();
const notificationRepo = new NotificationRepositoryMongo();


// === Usecase instances ===
const createTransaction = new CreateTransaction(
  transactionRepo,
  budgetRepo,
  notificationRepo
);

const patchTransaction = new PatchTransaction(
  transactionRepo,
  budgetRepo,
  notificationRepo
);

const getMyTransactions = new GetMyTransactions(transactionRepo);

const deleteTransaction = new DeleteTransaction(transactionRepo, accountRepo);

// === Routes ===

// Transaction ekle
router.post("/", requireAuth, async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await createTransaction.execute({
      userId,

      accountId: req.body.accountId,

      amount: Number(req.body.amount),

      category: req.body.category,
      description: req.body.description,
      type: req.body.type,
      currency: req.body.currency,
      occurredAt: req.body.occurredAt,
    });

    res.status(201).json({ ok: true, transaction: result });
  } catch (err) {
    console.error("CreateTransaction error:", err);

    const code = err.message;

    const statusMap = {
      AMOUNT_INVALID: 400,
      CATEGORY_REQUIRED: 400,
      TYPE_INVALID: 400,
      ACCOUNT_ID_REQUIRED: 400,
      ACCOUNT_NOT_FOUND: 404,
      INSUFFICIENT_BALANCE: 400,
    };

    const status = statusMap[code] || 500;

    res.status(status).json({
      ok: false,
      message: code,
    });
  }
});

// Transaction Güncelle
// Transaction güncelle (PATCH)
router.patch("/:id", requireAuth, async (req, res) => {
  try {
    const userId = req.user.userId;
    const transactionId = req.params.id;

    const result = await patchTransaction.execute({
      userId,
      transactionId,

      // İstersen accountId değişebilir
      accountId: req.body.accountId,

      amount: req.body.amount !== undefined ? Number(req.body.amount) : undefined,

      category: req.body.category,
      description: req.body.description,
      type: req.body.type,
      currency: req.body.currency,
      occurredAt: req.body.occurredAt,
    });

    res.status(200).json({ ok: true, transaction: result });
  } catch (err) {
    console.error("PatchTransaction error:", err);

    const code = err.message;

    const statusMap = {
      TRANSACTION_ID_REQUIRED: 400,
      TRANSACTION_NOT_FOUND: 404,

      AMOUNT_INVALID: 400,
      CATEGORY_REQUIRED: 400,
      TYPE_INVALID: 400,
      ACCOUNT_ID_REQUIRED: 400,
      ACCOUNT_NOT_FOUND: 404,

      // Update sırasında da geçerli olabilir
      INSUFFICIENT_BALANCE: 400,
    };

    const status = statusMap[code] || 500;

    res.status(status).json({
      ok: false,
      message: code,
    });
  }
});

// Transaction listele
router.get("/", requireAuth, async (req, res) => {
  try {
    const userId = req.user.userId;
    console.log("router HIT query.accountId =", req.query?.accountId);
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

// Transaction sil
router.delete("/:id", requireAuth, async (req, res) => {
  try {
    const userId = req.user.userId;
    const transactionId = req.params.id;

    const result = await deleteTransaction.execute({
      userId,
      transactionId,
    });

    // result: silinen transaction veya { deleted: true } gibi bir şey olabilir
    return res.status(200).json({
      ok: true,
      transaction: result, // istemezsen kaldır: sadece ok:true döndür
    });
  } catch (err) {
    console.error("DeleteTransaction error:", err);

    const code = err.message;

    const statusMap = {
      TRANSACTION_ID_REQUIRED: 400,
      TRANSACTION_NOT_FOUND: 404,
      ACCOUNT_NOT_FOUND: 404, // balance geri alma sırasında gerekebilir
    };

    const status = statusMap[code] || 500;

    return res.status(status).json({
      ok: false,
      message: code,
    });
  }
});

module.exports = router;
