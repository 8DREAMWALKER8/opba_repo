class CheckBudgetBreaches {
  constructor({ budgetRepo, transactionRepo, notificationRepo }) {
    this.budgetRepo = budgetRepo;
    this.transactionRepo = transactionRepo;
    this.notificationRepo = notificationRepo;
  }

  async execute({ userId, category, occurredAt, currency = "TRY" }) {
    // 1) budget var mı?
    const budget = await this.budgetRepo.findActiveByUserAndCategory(userId, category);
    if (!budget) return { ok: true, breached: false, reason: "NO_BUDGET" };

    const limit = Number(budget.limitAmount);
    if (!Number.isFinite(limit)) return { ok: true, breached: false, reason: "INVALID_LIMIT" };

    // 2) ay aralığı (monthly)
    const { from, to } = this._getMonthlyRange(occurredAt ? new Date(occurredAt) : new Date());

    // 3) harcama toplamı (expense)
    const spent = await this.transactionRepo.sumExpensesByUserAndCategoryBetween(
      userId,
      category,
      from,
      to,
      currency
    );

    // 4) breach?
    const breached = spent > limit;

    if (breached) {
      await this.notificationRepo.create({
        userId,
        type: "BUDGET_EXCEEDED",
        title: "Bütçe limiti aşıldı",
        message: `${category} bütçesi aşıldı. Limit: ${limit} ${currency}, Harcama: ${spent} ${currency}`,
        meta: {
          category,
          limit,
          spent,
          from,
          to,
          budgetId: budget._id || budget.id,
        },
      });
    }

    return { ok: true, breached, spent, limit, from, to };
  }

  _getMonthlyRange(date) {
    const d = new Date(date);
    const from = new Date(d.getFullYear(), d.getMonth(), 1, 0, 0, 0, 0);
    const to = new Date(d.getFullYear(), d.getMonth() + 1, 1, 0, 0, 0, 0);
    return { from, to };
  }
}

module.exports = CheckBudgetBreaches;
