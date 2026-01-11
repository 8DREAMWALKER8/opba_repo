class SetBudgetLimit {
  constructor(budgetRepo) {
    this.budgetRepo = budgetRepo;
  }

  _badRequest(code) {
    const err = new Error(code);
    err.statusCode = 400;
    return err;
  }

  async execute({ userId, category, limit, month, year, period, currency }) {
    // basit validasyon
    if (!userId) throw this._badRequest("USER_ID_REQUIRED");
    if (!category) throw this._badRequest("CATEGORY_REQUIRED");
    if (limit === undefined || limit === null) throw this._badRequest("LIMIT_IS_REQUIRED");
    if (!month) throw this._badRequest("MONTH_IS_REQUIRED");
    if (!year) throw this._badRequest("YEAR_IS_REQUIRED");

    const limitNum = Number(limit);
    if (!Number.isFinite(limitNum)) throw this._badRequest("INVALID_LIMIT");

    const monthNum = Number(month);
    if (!Number.isFinite(monthNum) || monthNum < 1 || monthNum > 12) {
      throw this._badRequest("INVALID_MONTH");
    }

    const yearNum = Number(year);
    if (!Number.isFinite(yearNum) || yearNum < 2000 || yearNum > 2100) {
      throw this._badRequest("INVALID_YEAR");
    }

    return this.budgetRepo.upsertBudget(userId, {
      category,
      limit: limitNum,
      month: monthNum,
      year: yearNum,
      period: period || "monthly",
      currency: currency,
    });
  }
}

module.exports = SetBudgetLimit;
