const BankAccount = require("../models/BankAccountModel");

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
}

module.exports = BankAccountRepositoryMongo;
