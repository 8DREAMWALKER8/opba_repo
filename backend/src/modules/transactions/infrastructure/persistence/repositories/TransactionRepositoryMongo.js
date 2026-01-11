// Bu sınıf Transaction işlemlerinin MongoDB tarafındaki veritabanı işlerini yapar.
// İş eklenince/silinince hesap bakiyesini de günceller; update’te ise transaction + bakiye değişiklikleri tutarlı olsun diye session/transaction kullanır.

const TransactionModel = require("../models/TransactionModel");
const mongoose = require("mongoose");
const { Types } = mongoose;

const BankAccountModel = require("../../../../accounts/infrastructure/persistence/models/BankAccountModel");

function escapeRegex(str) {
  return String(str).replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

class TransactionRepositoryMongo {
  async create(txEntity) {
    const accountId =
      typeof txEntity.accountId === "string"
        ? new mongoose.Types.ObjectId(txEntity.accountId)
        : txEntity.accountId;

    const userObjectId =
      typeof txEntity.userId === "string"
        ? new mongoose.Types.ObjectId(txEntity.userId)
        : txEntity.userId;

    const account = await BankAccountModel.findOne({
      _id: accountId,
      userId: userObjectId,
      isActive: true,
    }).lean();

    if (!account) {
      throw new Error("ACCOUNT_NOT_FOUND");
    }

    if (txEntity.type === "expense") {
      const currentBalance = Number(account.balance) || 0;
      if (currentBalance < Number(txEntity.amount)) {
        throw new Error("INSUFFICIENT_BALANCE");
      }
    }

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

  async updateByIdForUser(transactionId, userId, txEntity) {
    const txObjectId =
      typeof transactionId === "string"
        ? new mongoose.Types.ObjectId(transactionId)
        : transactionId;

    const userObjectId =
      typeof userId === "string"
        ? new mongoose.Types.ObjectId(userId)
        : userId;

    const newAccountId =
      typeof txEntity.accountId === "string"
        ? new mongoose.Types.ObjectId(txEntity.accountId)
        : txEntity.accountId;

    const session = await mongoose.startSession();

    try {
      let updatedDoc;

      await session.withTransaction(async () => {
        const existing = await TransactionModel.findOne({
          _id: txObjectId,
          userId: userObjectId,
        })
          .session(session)
          .lean();

        if (!existing) {
          throw new Error("TRANSACTION_NOT_FOUND");
        }

        const oldAccountId =
          typeof existing.accountId === "string"
            ? new mongoose.Types.ObjectId(existing.accountId)
            : existing.accountId;

        const newAccount = await BankAccountModel.findOne({
          _id: newAccountId,
          userId: userObjectId,
          isActive: true,
        })
          .session(session)
          .lean();

        if (!newAccount) {
          throw new Error("ACCOUNT_NOT_FOUND");
        }

        const oldDelta =
          existing.type === "income"
            ? Number(existing.amount)
            : -Number(existing.amount);

        const nextType = txEntity.type ?? existing.type;
        const nextAmount =
          txEntity.amount !== undefined ? Number(txEntity.amount) : Number(existing.amount);

        const newDelta =
          nextType === "income" ? Number(nextAmount) : -Number(nextAmount);

        const sameAccount = String(oldAccountId) === String(newAccountId);

        if (sameAccount) {
          const netChange = (-oldDelta) + newDelta;
          if (netChange < 0) {
            const currentBalance = Number(newAccount.balance) || 0;
            if (currentBalance < Math.abs(netChange)) {
              throw new Error("INSUFFICIENT_BALANCE");
            }
          }
        } else {
          if (newDelta < 0) {
            const currentBalance = Number(newAccount.balance) || 0;
            if (currentBalance < Math.abs(newDelta)) {
              throw new Error("INSUFFICIENT_BALANCE");
            }
          }

          const oldAccount = await BankAccountModel.findOne({
            _id: oldAccountId,
            userId: userObjectId,
            isActive: true,
          })
            .session(session)
            .lean();

          if (!oldAccount) {
            throw new Error("ACCOUNT_NOT_FOUND");
          }
        }

        const updatePayload = {
          accountId: newAccountId,
          userId: userObjectId,
          amount: nextAmount,
          category: txEntity.category ?? existing.category,
          description: txEntity.description ?? existing.description,
          type: nextType,
          currency: txEntity.currency ?? existing.currency,
          occurredAt: txEntity.occurredAt ?? existing.occurredAt,
        };

        const updTx = await TransactionModel.findOneAndUpdate(
          { _id: txObjectId, userId: userObjectId },
          { $set: updatePayload },
          { new: true, session }
        );

        if (!updTx) {
          throw new Error("TRANSACTION_NOT_FOUND");
        }

        updatedDoc = updTx.toObject();

        if (sameAccount) {
          const netChange = (-oldDelta) + newDelta;
          const updAcc = await BankAccountModel.updateOne(
            { _id: newAccountId, userId: userObjectId, isActive: true },
            { $inc: { balance: netChange } },
            { session }
          );

          if (updAcc.matchedCount === 0) throw new Error("ACCOUNT_NOT_FOUND");
        } else {
          const updOld = await BankAccountModel.updateOne(
            { _id: oldAccountId, userId: userObjectId, isActive: true },
            { $inc: { balance: -oldDelta } },
            { session }
          );
          if (updOld.matchedCount === 0) throw new Error("ACCOUNT_NOT_FOUND");

          const updNew = await BankAccountModel.updateOne(
            { _id: newAccountId, userId: userObjectId, isActive: true },
            { $inc: { balance: newDelta } },
            { session }
          );
          if (updNew.matchedCount === 0) throw new Error("ACCOUNT_NOT_FOUND");
        }
      });

      return updatedDoc;
    } finally {
      session.endSession();
    }
  }

  async findByIdForUser(transactionId, userId) {
    if (!transactionId || !userId) return null;

    const txObjectId =
      typeof transactionId === "string"
        ? new mongoose.Types.ObjectId(transactionId)
        : transactionId;

    const userObjectId =
      typeof userId === "string"
        ? new mongoose.Types.ObjectId(userId)
        : userId;

    const doc = await TransactionModel.findOne({
      _id: txObjectId,
      userId: userObjectId,
    }).lean();

    return doc || null;
  }

   async deleteByIdForUser(transactionId, userId) {
    if (!transactionId || !userId) return null;

    const txObjectId =
      typeof transactionId === "string"
        ? new mongoose.Types.ObjectId(transactionId)
        : transactionId;

    const userObjectId =
      typeof userId === "string"
        ? new mongoose.Types.ObjectId(userId)
        : userId;

    const doc = await TransactionModel.findOneAndDelete({
      _id: txObjectId,
      userId: userObjectId,
    });

    return doc ? doc.toObject() : null;
  }

  async findByUserId(userId, opts = {}) {
    const { limit = 50, skip = 0, type, category, accountId } = opts;

    const filter = { userId };
    if (type) filter.type = type;
    if (category) filter.category = category;
    if (accountId) {
      if (!Types.ObjectId.isValid(accountId)) {
        return res.status(400).json({ message: "Invalid accountId" });
      }
      filter.accountId = new Types.ObjectId(accountId);
    }

    const items = await TransactionModel.find(filter)
      .sort({ occurredAt: -1, createdAt: -1 })
      .skip(Number(skip))
      .limit(Number(limit))
      .lean();

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

  /**
   * Budget entegrasyonu için (FX'li):
   * - Period içindeki expense tx'leri çeker (category opsiyonel)
   * - fxRateRepo.getLatest() ile en güncel kurları alır
   * - Her tx amount'unu targetCurrency'ye çevirir
   * - Toplamı döndürür
   *
   * rateToTRY varsayımı:
   *   1 {currency} = rateToTRY TRY
   *
   * Dönüşüm:
   *   amount_in_TRY = amount * rateToTRY(txCurrency)
   *   amount_in_target = amount_in_TRY / rateToTRY(targetCurrency)
   *
   * TRY için rateToTRY = 1 kabul edilir.
   */
  async sumExpensesByUserAndCategoryBetweenFx({
    userId,
    category,          // optional
    from,              // Date (inclusive)
    to,                // Date (exclusive)
    targetCurrency = "TRY",
    fxRateRepo,        // instance of FxRateRepositoryMongo
  }) {
    if (!userId) throw new Error("USER_ID_REQUIRED");
    if (!from || !to) throw new Error("PERIOD_REQUIRED");
    if (!fxRateRepo || typeof fxRateRepo.getLatest !== "function") {
      throw new Error("FX_REPO_REQUIRED");
    }

    const userObjectId =
      typeof userId === "string" ? new mongoose.Types.ObjectId(userId) : userId;

    const normalizedTarget = String(targetCurrency || "TRY").trim().toUpperCase();

    // 1) Period tx'leri çek (expense)
    const match = {
      userId: userObjectId,
      type: "expense",
      occurredAt: { $gte: from, $lt: to },
    };
    if (category) match.category = category;

    // Sadece lazım olan alanlar
    const txs = await TransactionModel.find(match)
      .select({ amount: 1, currency: 1 })
      .lean();

    if (!txs.length) return 0;

    // 2) FX rates (en güncel) -> map
    // getLatest(limit) zaten date desc ile geliyor, aynı currency için birden fazla varsa ilkini alacağız.
    const fxDocs = await fxRateRepo.getLatest(500);

    const rateToTRYByCur = new Map();
    rateToTRYByCur.set("TRY", 1);

    for (const d of fxDocs) {
      const cur = String(d.currency || "").trim().toUpperCase();
      const r = Number(d.rateToTRY);
      if (!cur || !Number.isFinite(r) || r <= 0) continue;
      if (!rateToTRYByCur.has(cur)) rateToTRYByCur.set(cur, r);
    }

    // Target rate var mı?
    const targetRate = rateToTRYByCur.get(normalizedTarget);
    if (!targetRate) {
      throw new Error("TARGET_CURRENCY_RATE_NOT_FOUND");
    }

    // 3) Convert + sum
    let total = 0;

    for (const tx of txs) {
      const txCur = String(tx.currency || "TRY").trim().toUpperCase();
      const amount = Number(tx.amount) || 0;

      if (amount === 0) continue;

      const txRate = rateToTRYByCur.get(txCur);
      if (!txRate) {
        // İstersen "skip" yapabilirsin; ben hata fırlatıyorum ki eksik kur fark edilsin.
        throw new Error(`FX_RATE_NOT_FOUND_${txCur}`);
      }

      // amount -> TRY -> target
      const amountInTRY = amount * txRate;
      const amountInTarget = amountInTRY / targetRate;

      total += amountInTarget;
    }

    // İstersen rounding:
    // return Math.round(total * 100) / 100;
    return total;
  }

  async countSimilarExpensesBetween({ userId, key, amount, currency = "TRY", from, to }) {
    const userObjectId =
      typeof userId === "string" ? new mongoose.Types.ObjectId(userId) : userId;

    const amt = Number(amount);
    const safeKey = escapeRegex(String(key).trim());

    return TransactionModel.countDocuments({
      userId: userObjectId,
      type: "expense",
      currency,
      amount: amt,
      occurredAt: { $gte: from, $lt: to },

      $or: [
        { description: { $regex: `^${safeKey}$`, $options: "i" } },
        { category: String(key).trim() },
      ],
    });
  }
}

module.exports = TransactionRepositoryMongo;
