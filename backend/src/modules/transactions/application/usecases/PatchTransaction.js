// PatchTransaction.js
const TransactionEntity = require("../../domain/TransactionEntity");
const BudgetRules = require("../../../budgets/domain/services/BudgetRules");

class PatchTransaction {
  constructor(transactionRepo, budgetRepo, notificationRepo) {
    this.transactionRepo = transactionRepo;
    this.budgetRepo = budgetRepo;
    this.notificationRepo = notificationRepo;
  }

  /**
   * PATCH semantics:
   * - Only apply fields that are not undefined
   * - Convert types where needed (amount -> Number, occurredAt -> Date)
   */
  async execute({
    userId,
    transactionId,
    accountId,
    amount,
    category,
    description,
    type,
    currency,
    occurredAt,
  }) {
    if (!transactionId) throw new Error("TRANSACTION_ID_REQUIRED");

    // Mevcut transaction'ı bul (user'a ait olmalı)
    const existing = await this.transactionRepo.findByUserId(
      transactionId,
      userId
    );
    if (!existing) throw new Error("TRANSACTION_NOT_FOUND");

    // Patch objesi: sadece gelen alanlar
    const patch = {};

    if (accountId !== undefined) patch.accountId = accountId;
    if (category !== undefined) patch.category = category;
    if (description !== undefined) patch.description = description;
    if (type !== undefined) patch.type = type;
    if (currency !== undefined) patch.currency = currency;

    if (amount !== undefined) patch.amount = Number(amount);
    if (occurredAt !== undefined) {
      patch.occurredAt = occurredAt ? new Date(occurredAt) : new Date();
    }

    // Domain entity üzerinden (istersen validation burada olur)
    // Not: TransactionEntity'n senin projende validate ediyorsa patch'i entity ile merge ediyoruz.
    const merged = new TransactionEntity({
      ...existing,
      ...patch,
      userId, // güvenlik: userId asla client'tan gelmesin
    });

    // Persist update
    const updated = await this.transactionRepo.updateByIdForUser(
      transactionId,
      userId,
      merged
    );

    // Expense değilse kontroller yok
    if (!updated || updated.type !== "expense") return updated;

    // Budget/duplicate kontrollerini update sonrası tekrar değerlendirelim
    const txDate = updated.occurredAt ? new Date(updated.occurredAt) : new Date();
    const month = txDate.getMonth() + 1;
    const year = txDate.getFullYear();

    const { from, to } = BudgetRules.getMonthlyRange(txDate);
    const usedCurrency = updated.currency || currency || "TRY";

    // Duplicate kontrolü (create ile aynı mantık)
    const rawKey =
      typeof updated.description === "string" && updated.description.trim()
        ? updated.description.trim()
        : (updated.category || "");

    const key = String(rawKey).toLowerCase();

    if (key) {
      const amt = Number(updated.amount);

      const count = await this.transactionRepo.countSimilarExpensesBetween({
        userId,
        key,
        amount: amt,
        currency: usedCurrency,
        from,
        to,
      });

      // Create ile aynı davranış: 2 olunca 1 bildirim
      // İstersen update’te spam'i engellemek için ayrıca meta ile check yapabiliriz.
      if (count === 2) {
        await this.notificationRepo.create({
          userId,
          type: "DUPLICATE_CHARGE",
          title: "Tekrarlayan işlem tespit edildi.",
          message: `"${rawKey}" için aynı ay içinde ${amt} ${usedCurrency} tutarında 2 işlem göründü.`,
          meta: {
            key,
            rawKey,
            amount: amt,
            currency: usedCurrency,
            month,
            year,
            from,
            to,
            transactionId: updated._id || updated.id,
            source: "PATCH",
          },
        });
      }
    }

    // Budget kontrolü
    if (!updated.category) return updated;

    const budget = await this.budgetRepo.findActiveByUserAndCategory(
      userId,
      updated.category,
      month,
      year
    );
    if (!budget) return updated;

    const spent = await this.transactionRepo.sumExpensesByUserAndCategoryBetween(
      userId,
      updated.category,
      from,
      to,
      usedCurrency
    );

    const limit = Number(budget.limit);

    // %80 eşiği kontrolü
    const delta = Number(updated.amount);
    const spentBefore = Number.isFinite(delta) ? spent - delta : NaN;
    const threshold80 = BudgetRules.getNearLimitThreshold(limit, 0.8);

    const crossed80 =
      Number.isFinite(limit) &&
      !BudgetRules.isBreached(spent, limit) &&
      BudgetRules.crossedUpward(spentBefore, spent, threshold80);

    if (crossed80) {
      await this.notificationRepo.create({
        userId,
        type: "BUDGET_NEAR_LIMIT",
        title: "Bütçe limitine yaklaşıldı",
        message: BudgetRules.buildNearLimitMessage({
          category: updated.category,
          limit,
          spent,
          currency: usedCurrency,
          threshold: threshold80,
        }),
        meta: {
          category: updated.category,
          budgetId: budget._id,
          limit,
          spent,
          threshold: threshold80,
          month,
          year,
          from,
          to,
          source: "PATCH",
          transactionId: updated._id || updated.id,
        },
      });
    }

    // Limit aşımı bildirimi
    if (Number.isFinite(limit) && BudgetRules.isBreached(spent, limit)) {
      await this.notificationRepo.create({
        userId,
        type: "BUDGET_EXCEEDED",
        title: "Bütçe limiti aşıldı",
        message: BudgetRules.buildExceededMessage({
          category: updated.category,
          limit,
          spent,
          currency: usedCurrency,
        }),
        meta: {
          category: updated.category,
          budgetId: budget._id,
          limit,
          spent,
          month,
          year,
          from,
          to,
          source: "PATCH",
          transactionId: updated._id || updated.id,
        },
      });
    }

    return updated;
  }
}

module.exports = PatchTransaction;