// Transactions tarafının controller'ı gibi çalışıyor.
// Yani gelen HTTP isteklerini alıyor, içinden userId / body / params / query bilgilerini çekiyor
// ve işi asıl yapan usecase’lere paslıyor.
// Dönen sonucu da res.json ile client’a geri gönderiyor.

const TransactionRepositoryMongo = require("../infrastructure/persistence/repositories/TransactionRepositoryMongo");
const CreateTransaction = require("../application/usecases/CreateTransaction");
const GetMyTransactions = require("../application/usecases/GetMyTransactions");
const DeleteTransaction = require("../application/usecases/DeleteTransaction");
const fxRateRepo = require("../../fxrates/infrastructure/persistence/repositories/FxRateRepositoryMongo");  
const SyncTcbmRates = require("../../fxrates/application/usecases/SyncTcbmRates");
const AxiosHttpClient = require("../../fxrates/infrastructure/services/AxiosHttpClient");
const TcmbXmlParser = require("../../fxrates/infrastructure/services/TcmbXmlParser");


const syncTcbmRates = new SyncTcbmRates({
  httpClient: new AxiosHttpClient(),
  xmlParser: new TcmbXmlParser(),
  fxRateRepo,
  tcmbUrl: process.env.TCMB_URL,
});

const txRepo = new TransactionRepositoryMongo();
const createTx = new CreateTransaction(txRepo);
const getMyTx = new GetMyTransactions(txRepo, fxRateRepo, syncTcbmRates);
const deleteTx = new DeleteTransaction(txRepo);

async function createTransaction(req, res) {
  const userId = req.user?.userId || req.user?.id || req.user?._id;

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
  const userId = req.user?.userId || req.user?.id || req.user?._id;

  const transactionId = req.params?.id;

  const deleted = await deleteTx.execute({
    userId,
    transactionId,
  });

  return res.status(200).json({ ok: true, transaction: deleted });
}

async function patchTransaction(req, res) {
  const userId = req.user?.userId || req.user?.id || req.user?._id;

  const transactionId = req.params?.id;

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

  const { limit, skip, type, category, accountId, currency } = req.query;
  const items = await getMyTx.execute({
    userId,
    accountId,
    limit: limit ? Number(limit) : 50,
    skip: skip ? Number(skip) : 0,
    type,
    category,
    selectedCurrency: currency,
  });

  return res.json({ ok: true, transactions: items });
}

module.exports = {
  createTransaction,
  getMyTransactions,
  patchTransaction,
  deleteTransaction,
};
