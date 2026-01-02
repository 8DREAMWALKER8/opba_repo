const TransactionModel = require("../models/TransactionModel");
const mongoose = require("mongoose");

class TransactionRepositoryMongo {
  async create(txEntity) {
    const doc = await TransactionModel.create({
      userId: txEntity.userId,
      amount: txEntity.amount,
      category: txEntity.category,
      description: txEntity.description,
      type: txEntity.type,
      currency: txEntity.currency,
      occurredAt: txEntity.occurredAt,
    });

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
      .limit(Number(limit));

    return items.map((d) => d.toObject());
  }

  /**
   * Budget entegrasyonu için: belli tarih aralığında (örn. ay) belirli kategori expense toplamını döner.
   * from inclusive, to exclusive.
   */
  async sumExpensesByUserAndCategoryBetween(userId, category, from, to, currency = "TRY") {
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
