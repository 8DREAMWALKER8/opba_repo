const BankAccount = require("../models/BankAccountModel");
const mongoose = require("mongoose");

class BankAccountRepositoryMongo {
  async listActiveByUser(userId) {
    return BankAccount.find({ userId, isActive: true }).sort({ createdAt: -1 });
  }

  async createForUser(userId, data) {
    return BankAccount.create({ ...data, userId, isActive: true });
  }

  async deactivate(userId, accountId) {
    return BankAccount.findOneAndUpdate(
      { _id: accountId, userId },
      { $set: { isActive: false } },
      { new: true }
    );
  }

  async incBalanceByIdForUser(accountId, userId, delta) {
    if (delta === undefined || delta === null) {
      throw new Error("AMOUNT_INVALID");
    }

    const accountObjectId =
      typeof accountId === "string"
        ? new mongoose.Types.ObjectId(accountId)
        : accountId;

    const userObjectId =
      typeof userId === "string"
        ? new mongoose.Types.ObjectId(userId)
        : userId;

    const upd = await BankAccount.updateOne(
      { _id: accountObjectId, userId: userObjectId, isActive: true },
      { $inc: { balance: Number(delta) } }
    );

    if (upd.matchedCount === 0) {
      throw new Error("ACCOUNT_NOT_FOUND");
    }

    return true;
  }

  async findByUserId(accountId, userId) {
    if (!accountId || !userId) return null;

    const accountObjectId =
      typeof accountId === "string"
        ? new mongoose.Types.ObjectId(accountId)
        : accountId;

    const userObjectId =
      typeof userId === "string"
        ? new mongoose.Types.ObjectId(userId)
        : userId;

    const doc = await BankAccount.findOne({
      _id: accountObjectId,
      userId: userObjectId,
      isActive: true, // aktiflik kontrolü istemiyorsan kaldır
    }).lean();

    return doc || null;
  }
}

module.exports = BankAccountRepositoryMongo;
