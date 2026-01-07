const BudgetRules = require("../../domain/services/BudgetRules");

class CheckBudgetBreaches {
  constructor({ budgetRepo, transactionRepo, notificationRepo }) {
    this.budgetRepo = budgetRepo;
    this.transactionRepo = transactionRepo;
    this.notificationRepo = notificationRepo;
  }

  // deltaAmount = bu transaction’ın amount’u (eşik geçişini yakalamak için)
  async execute({ userId, category, occurredAt, currency = "TRY", deltaAmount }) {
    const txDate = occurredAt ? new Date(occurredAt) : new Date();
    const month = txDate.getMonth() + 1;
    const year = txDate.getFullYear();

    // budget var mı
    const budget = await this.budgetRepo.findActiveByUserAndCategory(userId, category, month, year);
    if (!budget) return { ok: true, breached: false, reason: "NO_BUDGET", month, year };

    const limit = Number(budget.limit);
    if (!Number.isFinite(limit)) return { ok: true, breached: false, reason: "INVALID_LIMIT", month, year };

    // ay aralığı (monthly)
    const { from, to } = BudgetRules.getMonthlyRange(txDate);

    // harcama toplamı (expense)
    const spent = await this.transactionRepo.sumExpensesByUserAndCategoryBetween(
      userId,
      category,
      from,
      to,
      currency
    );

    // %80 eşiği (eşik geçişi)
    const d = Number(deltaAmount);
    const spentBefore = Number.isFinite(d) ? spent - d : NaN;

    const threshold80 = BudgetRules.getNearLimitThreshold(limit, 0.8);
    const crossed80 =
      !BudgetRules.isBreached(spent, limit) &&
      BudgetRules.crossedUpward(spentBefore, spent, threshold80);

    if (crossed80) {
      await this.notificationRepo.create({
        userId,
        type: "BUDGET_NEAR_LIMIT",
        title: "Bütçe limitine yaklaşıldı",
        message: BudgetRules.buildNearLimitMessage({
          category,
          limit,
          spent,
          currency,
          threshold: threshold80,
        }),
        meta: {
          category,
          budgetId: budget._id || budget.id,
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

    // breach
    const breached = BudgetRules.isBreached(spent, limit);

    if (breached) {
      await this.notificationRepo.create({
        userId,
        type: "BUDGET_EXCEEDED",
        title: "Bütçe limiti aşıldı",
        message: BudgetRules.buildExceededMessage({ category, limit, spent, currency }),
        meta: {
          category,
          budgetId: budget._id || budget.id,
          limit,
          spent,
          month,
          year,
          from,
          to,
        },
      });
    }

    return {
      ok: true,
      breached,
      near80: crossed80,
      spent,
      limit,
      from,
      to,
      month,
      year,
      threshold80,
      spentBefore,
    };
  }
}

module.exports = CheckBudgetBreaches;
