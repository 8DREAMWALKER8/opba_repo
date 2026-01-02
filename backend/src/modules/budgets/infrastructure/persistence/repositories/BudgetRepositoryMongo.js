const BudgetModel = require("../models/BudgetModel");

class BudgetRepositoryMongo {
  // Kullanıcının tüm budget kayıtlarını getir
  async findByUser(userId) {
    return BudgetModel.find({ userId }).sort({ createdAt: -1 }).lean();
  }

  // Aynı userId + category + month + year için upsert (modelindeki unique index ile uyumlu)
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

  // Transaction sonrası kontrol için
  async findActiveByUserAndCategory(userId, category, month, year) {
    return BudgetModel.findOne({ userId, category, month, year }).lean();
  }
}

module.exports = BudgetRepositoryMongo;
