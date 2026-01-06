const TransactionRepositoryMongo = require("../infrastructure/persistence/repositories/TransactionRepositoryMongo");
const CreateTransaction = require("../application/usecases/CreateTransaction");
const GetMyTransactions = require("../application/usecases/GetMyTransactions");

const txRepo = new TransactionRepositoryMongo();
const createTx = new CreateTransaction(txRepo);
const getMyTx = new GetMyTransactions(txRepo);

async function createTransaction(req, res) {
  console.log("controller HIT body.accountId =", req.body?.accountId);
  // requireAuth middleware req.user içine payload koyuyor (senin auth.js)
  const userId = req.user?.userId || req.user?.id || req.user?._id;

  // EKLENDİ: accountId'yi body'den al
 const { accountId, amount, category, description, type, currency, occurredAt } = req.body;

  const created = await createTx.execute({
    userId,
    accountId,
    amount: Number(amount),
    category,
    description,
    type,
    currency,
    occurredAt,
  });

  return res.status(201).json({ ok: true, transaction: created });
}

async function getMyTransactions(req, res) {
  const userId = req.user?.userId || req.user?.id || req.user?._id;

  const { limit, skip, type, category } = req.query;

  const items = await getMyTx.execute({
    userId,
    limit: limit ? Number(limit) : 50,
    skip: skip ? Number(skip) : 0,
    type,
    category,
  });

  return res.json({ ok: true, transactions: items });
}

module.exports = {
  createTransaction,
  getMyTransactions,
};
