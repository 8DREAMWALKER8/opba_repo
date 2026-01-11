/*
  Burada uygulamanın dış dünyaya açılan endpoint’leri tanımlanır.
  İstemciden gelen HTTP istekleri burada karşılanır ve ilgili usecase’lere yönlendirilir.
 
  routes.js dosyası gelen isteği alır, gerekli verileri ayıklar ve application katmanındaki usecase’leri çağırır.
 
  Tüm route’lar requireAuth middleware’i ile korunur.
  Bu sayede her işlem sadece giriş yapmış kullanıcılar için çalışır ve user bilgisi req.user üzerinden alınır.
 */

const express = require("express");
const router = express.Router();

const { requireAuth } = require("../../../middleware/auth");

const TransactionRepositoryMongo = require("../infrastructure/persistence/repositories/TransactionRepositoryMongo");
const BudgetRepositoryMongo = require("../../budgets/infrastructure/persistence/repositories/BudgetRepositoryMongo");
const NotificationRepositoryMongo = require("../../notifications/infrastructure/persistence/repositories/NotificationRepositoryMongo");
const BankAccountRepositoryMongo = require("../../accounts/infrastructure/persistence/repositories/BankAccountRepositoryMongo");

const CreateTransaction = require("../application/usecases/CreateTransaction");
const GetMyTransactions = require("../application/usecases/GetMyTransactions");
const PatchTransaction = require("../application/usecases/PatchTransaction");
const DeleteTransaction = require("../application/usecases/DeleteTransaction");
const FxRateRepositoryMongo = require("../../fxrates/infrastructure/persistence/repositories/FxRateRepositoryMongo");
const SyncTcbmRates = require("../../fxrates/application/usecases/SyncTcbmRates");
const AxiosHttpClient = require("../../fxrates/infrastructure/services/AxiosHttpClient");
const TcmbXmlParser = require("../../fxrates/infrastructure/services/TcmbXmlParser");

const transactionRepo = new TransactionRepositoryMongo();
const accountRepo = new BankAccountRepositoryMongo();
const budgetRepo = new BudgetRepositoryMongo();
const notificationRepo = new NotificationRepositoryMongo();
const fxRateRepo = new FxRateRepositoryMongo();


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

const syncTcbmRates = new SyncTcbmRates({
  httpClient: new AxiosHttpClient(),
  xmlParser: new TcmbXmlParser(),
  fxRateRepo,
  tcmbUrl: process.env.TCMB_URL,
});

const getMyTransactions = new GetMyTransactions({transactionRepo, fxRateRepo, syncTcbmRates});

const deleteTransaction = new DeleteTransaction(transactionRepo, accountRepo);

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

router.patch("/:id", requireAuth, async (req, res) => {
  try {
    const userId = req.user.userId;
    const transactionId = req.params.id;

    const result = await patchTransaction.execute({
      userId,
      transactionId,

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

    const code = err.message;

    const statusMap = {
      TRANSACTION_ID_REQUIRED: 400,
      TRANSACTION_NOT_FOUND: 404,

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

router.get("/", requireAuth, async (req, res) => {
  try {
    const userId = req.user.userId;
    console.log("Currency in routes:", req.query.currency);
    const { limit, skip, type, category, accountId, currency } = req.query;
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

router.delete("/:id", requireAuth, async (req, res) => {
  try {
    const userId = req.user.userId;
    const transactionId = req.params.id;

    const result = await deleteTransaction.execute({
      userId,
      transactionId,
    });

    return res.status(200).json({
      ok: true,
      transaction: result,
    });
  } catch (err) {
    console.error("DeleteTransaction error:", err);

    const code = err.message;

    const statusMap = {
      TRANSACTION_ID_REQUIRED: 400,
      TRANSACTION_NOT_FOUND: 404,
      ACCOUNT_NOT_FOUND: 404,
    };

    const status = statusMap[code] || 500;

    return res.status(status).json({
      ok: false,
      message: code,
    });
  }
});

module.exports = router;
