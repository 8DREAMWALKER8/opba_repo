const TransactionModel = require("../models/TransactionModel");
const mongoose = require("mongoose");
const { Types } = mongoose;

// BankAccount model (doğru path)
const BankAccountModel = require("../../../../accounts/infrastructure/persistence/models/BankAccountModel");

// regex kaçış
function escapeRegex(str) {
  return String(str).replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

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
        // 1) Eski transaction'ı bul (user'a ait olmalı)
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

        // 2) Yeni account aktif mi / user'a ait mi?
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

        // 3) Bakiye düzeltmeleri için delta hesapla
        // Eski transaction'ın bakiyeye etkisi:
        const oldDelta =
          existing.type === "income"
            ? Number(existing.amount)
            : -Number(existing.amount);

        // Yeni transaction'ın bakiyeye etkisi:
        const nextType = txEntity.type ?? existing.type;
        const nextAmount =
          txEntity.amount !== undefined ? Number(txEntity.amount) : Number(existing.amount);

        const newDelta =
          nextType === "income" ? Number(nextAmount) : -Number(nextAmount);

        const sameAccount = String(oldAccountId) === String(newAccountId);

        // 4) INSUFFICIENT kontrolü (expense ise, update sonrası düşüş kadar kontrol)
        // Mantık: ilgili account'ta uygulanacak net değişim negatif ise bakiyeyi kontrol et.
        // sameAccount: netChange = -oldDelta + newDelta
        // farklı hesap: new account’a newDelta uygulanacak, old account’a -oldDelta uygulanacak
        if (sameAccount) {
          const netChange = (-oldDelta) + newDelta; // iade + yeni uygulama
          if (netChange < 0) {
            const currentBalance = Number(newAccount.balance) || 0;
            if (currentBalance < Math.abs(netChange)) {
              throw new Error("INSUFFICIENT_BALANCE");
            }
          }
        } else {
          // Yeni account tarafında negatif etki varsa kontrol et
          if (newDelta < 0) {
            const currentBalance = Number(newAccount.balance) || 0;
            if (currentBalance < Math.abs(newDelta)) {
              throw new Error("INSUFFICIENT_BALANCE");
            }
          }

          // Eski account aktif mi? (iade edeceğiz; aktif değilse de iade etmemek tutarsız olur)
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

        // 5) Transaction document update
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

        // 6) Balance update
        if (sameAccount) {
          const netChange = (-oldDelta) + newDelta; // iade + yeni
          const updAcc = await BankAccountModel.updateOne(
            { _id: newAccountId, userId: userObjectId, isActive: true },
            { $inc: { balance: netChange } },
            { session }
          );

          if (updAcc.matchedCount === 0) throw new Error("ACCOUNT_NOT_FOUND");
        } else {
          // Eski hesaba iade (oldDelta'yı geri al -> -oldDelta)
          const updOld = await BankAccountModel.updateOne(
            { _id: oldAccountId, userId: userObjectId, isActive: true },
            { $inc: { balance: -oldDelta } },
            { session }
          );
          if (updOld.matchedCount === 0) throw new Error("ACCOUNT_NOT_FOUND");

          // Yeni hesaba yeni delta uygula
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

  /**
   * Tekrarlayan işlem kontrolü için:
   * Aynı ay aralığında aynı amount + currency ile aynı "key" (description veya category) kaç kez var?
   * key: CreateTransaction tarafında lower-case gönderiyoruz.
   * description eşleşmesini case-insensitive regex ile yapıyoruz.
   */
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

      // description varsa onu yakalar, yoksa category için de şans tanır
      $or: [
        { description: { $regex: `^${safeKey}$`, $options: "i" } },
        { category: String(key).trim() },
      ],
    });
  }
}

module.exports = TransactionRepositoryMongo;
