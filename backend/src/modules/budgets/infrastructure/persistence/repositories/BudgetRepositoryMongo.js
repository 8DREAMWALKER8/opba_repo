const BudgetModel = require("../models/BudgetModel");
const mongoose = require("mongoose");

class BudgetRepositoryMongo {
  // kullanicinin budget kayıtlari
  async findByUser(userId) {
    return BudgetModel.find({ userId }).sort({ createdAt: -1 }).lean();
  }

  // güncelleme ekleme islemi
  async upsertBudget(userId, { category, limit, month, year, period = "monthly", currency }) {
    return BudgetModel.findOneAndUpdate(
      { userId, category, month, year },
      {
        $set: {
          limit: Number(limit),
          period,
          currency,
          month: Number(month),
          year: Number(year),
        },
      },
      { new: true, upsert: true, runValidators: true }
    ).lean();
  }

  async deleteByIdForUser(budgetId, userId) {
    const bId =
      typeof budgetId === "string" ? new mongoose.Types.ObjectId(budgetId) : budgetId;

    const uId =
      typeof userId === "string" ? new mongoose.Types.ObjectId(userId) : userId;

    const doc = await BudgetModel.findOneAndDelete({
      _id: bId,
      userId: uId,
    }).lean();

    return doc || null;
  }

  // belirli butceleri versa getirir
  async findActiveByUserAndCategory(userId, category, month, year) {
    return BudgetModel.findOne({ userId, category, month, year }).lean();
  }
}

module.exports = BudgetRepositoryMongo;
