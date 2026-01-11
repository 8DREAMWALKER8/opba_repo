/*
Bu sınıf BankAccount (MongoDB) ile tüm veritabanı işlemlerini yapar.
Use case’ler DB’ye direkt gitmez; repo üzerinden gider.
*/
const BankAccount = require("../models/BankAccountModel");
const mongoose = require("mongoose");
const { Types } = mongoose;

class BankAccountRepositoryMongo {
  _toObjectId(id) {
    if (!id || !Types.ObjectId.isValid(id)) {
      const e = new Error("INVALID_ID: " + id);
      e.statusCode = 400;
      throw e;
    }
    return new Types.ObjectId(id);
  }

  _normalizeUserId(userId) {
    if (!userId) {
      const e = new Error("USER_ID_REQUIRED");
      e.statusCode = 400;
      throw e;
    }
    return typeof userId === "string" ? this._toObjectId(userId) : userId;
  }

  async listActiveByUser(userId) {
    const uid = this._normalizeUserId(userId);
    return BankAccount.find({ userId: uid, isActive: true })
      .sort({ createdAt: -1 })
      .lean()
      .exec();
  }

  async createForUser(userId, data) {
    const uid = this._normalizeUserId(userId);
    return BankAccount.create({ ...data, userId: uid, isActive: true });
  }

  async deactivate(userId, accountId) {
    const uid = this._normalizeUserId(userId);
    const _id = this._toObjectId(accountId);

    return BankAccount.findOneAndDelete({ _id, userId: uid })
      .lean()
      .exec();
  }

  async findById(id) {
    console.log("[Repo findById] id:", id);
    const _id = this._toObjectId(id);
    return BankAccount.findOne({ _id }).lean().exec();
  }

  async findByIdForUser({ id, userId }) {
    console.log("[Repo findByIdForUser] id:", id, "userId:", userId);
    const _id = this._toObjectId(id);
    const uid = this._normalizeUserId(userId);

    return BankAccount.findOne({ _id, userId: uid }).lean().exec();
  }

  async updateById(id, patch) {
    console.log("[Repo updateById] id:", id);
    const _id = this._toObjectId(id);

    return BankAccount.findOneAndUpdate(
      { _id },
      { $set: patch },
      { new: true, runValidators: true }
    )
      .lean()
      .exec();
  }

  async updateByIdForUser({ id, userId, patch }) {
    console.log("[Repo updateByIdForUser] id:", id, "userId:", userId);
    const _id = this._toObjectId(id);
    const uid = this._normalizeUserId(userId);

    return BankAccount.findOneAndUpdate(
      { _id, userId: uid },
      { $set: patch },
      { new: true, runValidators: true }
    )
      .lean()
      .exec();
  }

  async incBalanceByIdForUser(accountId, userId, delta) {
    if (delta === undefined || delta === null) {
      throw new Error("AMOUNT_INVALID");
    }

    const _id =
      typeof accountId === "string" ? this._toObjectId(accountId) : accountId;
    const uid =
      typeof userId === "string" ? this._toObjectId(userId) : userId;

    const upd = await BankAccount.updateOne(
      { _id, userId: uid, isActive: true },
      { $inc: { balance: Number(delta) } }
    );

    if (upd.matchedCount === 0) {
      throw new Error("ACCOUNT_NOT_FOUND");
    }

    return true;
  }

  async findByUserId(accountId, userId) {
    if (!accountId || !userId) return null;

    const _id =
      typeof accountId === "string" ? this._toObjectId(accountId) : accountId;
    const uid = typeof userId === "string" ? this._toObjectId(userId) : userId;

    const doc = await BankAccount.findOne({
      _id,
      userId: uid,
      isActive: true,
    })
      .lean()
      .exec();

    return doc || null;
  }
}

module.exports = BankAccountRepositoryMongo;