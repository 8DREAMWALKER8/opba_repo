// CreateTransaction.js
const TransactionEntity = require("../../domain/TransactionEntity");
const BudgetRules = require("../../../budgets/domain/services/BudgetRules");

class CreateTransaction {
  constructor(transactionRepo, budgetRepo, notificationRepo) {
    this.transactionRepo = transactionRepo;
    this.budgetRepo = budgetRepo;
    this.notificationRepo = notificationRepo;
  }

  // accountId eklendi
  async execute({ userId, accountId, amount, category, description, type, currency, occurredAt }) {
    const entity = new TransactionEntity({
      userId,
      accountId,
      amount,
      category,
      description,
      type,
      currency,
      occurredAt: occurredAt ? new Date(occurredAt) : new Date(),
    });

    const created = await this.transactionRepo.create(entity);

    // sadece expense kontrolleri
    if (created.type !== "expense") return created;

    const txDate = created.occurredAt ? new Date(created.occurredAt) : new Date();
    const month = txDate.getMonth() + 1;
    const year = txDate.getFullYear();

    // Monthly range (aynı ay içinde duplicate kontrolü için lazım)
    const { from, to } = BudgetRules.getMonthlyRange(txDate);
    const usedCurrency = created.currency || currency || "TRY";

    // TEKRARLAYAN İŞLEM KONTROLÜ (aynı ay içinde 2. kez)
    // key: description varsa description, yoksa category
    // amount aynı
    // currency aynı
    // count == 2 olunca 1 kere bildir 
    const rawKey =
      typeof created.description === "string" && created.description.trim()
        ? created.description.trim()
        : (created.category || "");

    const key = String(rawKey).toLowerCase();

    if (key) {
      const amt = Number(created.amount);

      // countSimilarExpensesBetween({ userId, key, amount, currency, from, to })
      const count = await this.transactionRepo.countSimilarExpensesBetween({
        userId,
        key,
        amount: amt,
        currency: usedCurrency,
        from,
        to,
      });

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
            transactionId: created._id || created.id,
          },
        });
      }
    }

    // BUDGET KONTROLÜ 
    if (!created.category) return created;

    const budget = await this.budgetRepo.findActiveByUserAndCategory(
      userId,
      created.category,
      month,
      year
    );
    if (!budget) return created;

    const spent = await this.transactionRepo.sumExpensesByUserAndCategoryBetween(
      userId,
      created.category,
      from,
      to,
      usedCurrency
    );

    const limit = Number(budget.limit);

    // %80 eşiği kontrolü (bu transaction amount'u ile eşik geçişini yakala)
    const delta = Number(created.amount);
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
          category: created.category,
          limit,
          spent,
          currency: usedCurrency,
          threshold: threshold80,
        }),
        meta: {
          category: created.category,
          budgetId: budget._id,
          limit,
          spent,
          threshold: threshold80,
          month,
          year,
          from,
          to,
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
          category: created.category,
          limit,
          spent,
          currency: usedCurrency,
        }),
        meta: {
          category: created.category,
          budgetId: budget._id,
          limit,
          spent,
          month,
          year,
          from,
          to,
        },
      });
    }

    return created;
  }
}

module.exports = CreateTransaction;
