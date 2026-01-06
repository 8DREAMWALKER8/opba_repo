const TransactionModel = require("../models/TransactionModel");
const mongoose = require("mongoose");

// BankAccount model (doğru path)
const BankAccountModel = require("../../../../accounts/infrastructure/persistence/models/BankAccountModel");

class TransactionRepositoryMongo {
  async create(txEntity) {
    // accountId / userId ObjectId'a çevrilir
    const accountId =
      typeof txEntity.accountId === "string"
        ? new mongoose.Types.ObjectId(txEntity.accountId)
        : txEntity.accountId;

    const userObjectId =
      typeof txEntity.userId === "string"
        ? new mongoose.Types.ObjectId(txEntity.userId)
        : txEntity.userId;

    // account mevcut mu / user’a mı ait?
    const account = await BankAccountModel.findOne({
      _id: accountId,
      userId: userObjectId,
      isActive: true,
    }).lean();

    if (!account) {
      throw new Error("ACCOUNT_NOT_FOUND");
    }

    // expense ise insufficient kontrol
    if (txEntity.type === "expense") {
      const currentBalance = Number(account.balance) || 0;
      if (currentBalance < Number(txEntity.amount)) {
        throw new Error("INSUFFICIENT_BALANCE");
      }
    }

    // Transaction kaydet (accountId dahil)
    const doc = await TransactionModel.create({
      accountId,
      userId: userObjectId,
      amount: Number(txEntity.amount),
      category: txEntity.category,
      description: txEntity.description,
      type: txEntity.type,
      currency: txEntity.currency,
      occurredAt: txEntity.occurredAt,
    });

    // balance update (atomic $inc)
    const delta =
      txEntity.type === "income"
        ? Number(txEntity.amount)
        : -Number(txEntity.amount);

    const upd = await BankAccountModel.updateOne(
      { _id: accountId, userId: userObjectId, isActive: true },
      { $inc: { balance: delta } }
    );

    if (upd.matchedCount === 0) {
      throw new Error("ACCOUNT_NOT_FOUND");
    }

    return doc.toObject();
  }

  async findByUserId(userId, opts = {}) {
    const { limit = 50, skip = 0, type, category } = opts;

    const filter = { userId };
    if (type) filter.type = type;
    if (category) filter.category = category;

    const items = await TransactionModel.find(filter)
      .sort({ occurredAt: -1, createdAt: -1 })
      .skip(Number(skip))
      .limit(Number(limit))
      .lean();

    // _id bazlı tekilleştirme
    const seen = new Set();
    const unique = [];
    for (const t of items) {
      const id = String(t._id);
      if (seen.has(id)) continue;
      seen.add(id);
      unique.push(t);
    }

    return unique;
  }

  /**
   * Budget entegrasyonu için: belli tarih aralığında (örn. ay) belirli kategori expense toplamını döner.
   * from inclusive, to exclusive.
   */
  async sumExpensesByUserAndCategoryBetween(
    userId,
    category,
    from,
    to,
    currency = "TRY"
  ) {
    const userObjectId =
      typeof userId === "string" ? new mongoose.Types.ObjectId(userId) : userId;

    const res = await TransactionModel.aggregate([
      {
        $match: {
          userId: userObjectId,
          category,
          type: "expense",
          currency,
          occurredAt: { $gte: from, $lt: to },
        },
      },
      { $group: { _id: null, total: { $sum: "$amount" } } },
    ]);

    return res[0]?.total || 0;
  }
}

module.exports = TransactionRepositoryMongo;
