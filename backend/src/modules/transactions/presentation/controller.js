const TransactionRepositoryMongo = require("../infrastructure/persistence/repositories/TransactionRepositoryMongo");
const CreateTransaction = require("../application/usecases/CreateTransaction");
const GetMyTransactions = require("../application/usecases/GetMyTransactions");
const DeleteTransaction = require("../application/usecases/DeleteTransaction");

const txRepo = new TransactionRepositoryMongo();
const createTx = new CreateTransaction(txRepo);
const getMyTx = new GetMyTransactions(txRepo);
const deleteTx = new DeleteTransaction(txRepo);

async function createTransaction(req, res) {
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

async function deleteTransaction(req, res) {
  // requireAuth middleware req.user içine payload koyuyor (auth.js)
  const userId = req.user?.userId || req.user?.id || req.user?._id;

  // silinecek transaction id
  const transactionId = req.params?.id;

  const deleted = await deleteTx.execute({
    userId,
    transactionId,
  });

  return res.status(200).json({ ok: true, transaction: deleted });
}

async function patchTransaction(req, res) {
  // requireAuth middleware req.user içine payload koyuyor (auth.js)
  const userId = req.user?.userId || req.user?.id || req.user?._id;

  // ✅ Güncellenecek transaction id
  const transactionId = req.params?.id;

  // PATCH edilecek alanlar
  const {
    accountId,
    amount,
    category,
    description,
    type,
    currency,
    occurredAt,
  } = req.body;

  const updated = await patchTx.execute({
    userId,
    transactionId,

    // sadece gönderildiyse set et (PATCH semantics)
    ...(accountId !== undefined ? { accountId } : {}),
    ...(amount !== undefined ? { amount: Number(amount) } : {}),
    ...(category !== undefined ? { category } : {}),
    ...(description !== undefined ? { description } : {}),
    ...(type !== undefined ? { type } : {}),
    ...(currency !== undefined ? { currency } : {}),
    ...(occurredAt !== undefined ? { occurredAt } : {}),
  });

  return res.status(200).json({ ok: true, transaction: updated });
}

async function getMyTransactions(req, res) {
  const userId = req.user?.userId || req.user?.id || req.user?._id;

  const { limit, skip, type, category, accountId } = req.query;
  const items = await getMyTx.execute({
    userId,
    accountId,
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
  patchTransaction,
  deleteTransaction,
};
