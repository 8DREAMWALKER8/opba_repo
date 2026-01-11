const BudgetModel = require("../models/BudgetModel");

class BudgetRepositoryMongo {
  // kullanicinin budget kayıtlari
  async findByUser(userId) {
    return BudgetModel.find({ userId }).sort({ createdAt: -1 }).lean();
  }

  // güncelleme ekleme islemi
  async upsertBudget(userId, { category, limit, month, year, period = "monthly" }) {
    return BudgetModel.findOneAndUpdate(
      { userId, category, month, year },
      {
        $set: {
          limit: Number(limit),
          period,
          month: Number(month),
          year: Number(year),
        },
      },
      { new: true, upsert: true, runValidators: true }
    ).lean();
  }

  // belirli butceleri versa getirir
  async findActiveByUserAndCategory(userId, category, month, year) {
    return BudgetModel.findOne({ userId, category, month, year }).lean();
  }
}

module.exports = BudgetRepositoryMongo;
