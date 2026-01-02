class SetBudgetLimit {
  constructor(budgetRepo) {
    this.budgetRepo = budgetRepo;
  }

  async execute({ userId, category, limit, month, year, period }) {
    // basit validasyon
    if (!userId) throw new Error("userId is required");
    if (!category) throw new Error("category is required");
    if (limit === undefined || limit === null) throw new Error("limit is required");
    if (!month) throw new Error("month is required");
    if (!year) throw new Error("year is required");

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
