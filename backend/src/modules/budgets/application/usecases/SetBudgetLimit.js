class SetBudgetLimit {
  constructor(budgetRepo) {
    this.budgetRepo = budgetRepo;
  }

  async execute({ userId, category, limit, month, year, period }) {
    // basit validasyon
    if (!userId) throw new Error("USER_ID_REQUIRED");
    if (!category) throw new Error("CATEGORY_REQUIRED");
    if (limit === undefined || limit === null) throw new Error("LIMIT_IS_REQUIRED");
    if (!month) throw new Error("MONTH_IS_REQUIRED");
    if (!year) throw new Error("YEAR_IS_REQUIRED");

    return this.budgetRepo.upsertBudget(userId, {
      category,
      limit: Number(limit),
      month: Number(month),
      year: Number(year),
      period: period || "monthly",
    });
  }
}

module.exports = SetBudgetLimit;
