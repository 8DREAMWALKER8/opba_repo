

class DeleteBudget {
  constructor({ budgetRepo }) {
    this.budgetRepo = budgetRepo;
  }

  async execute({ userId, budgetId }) {
    if (!userId) throw new Error("USER_ID_REQUIRED");
    if (!budgetId) throw new Error("BUDGET_ID_REQUIRED");

    // repo methodu yoksa wiring hatası
    if (typeof this.budgetRepo.deleteByIdForUser !== "function") {
      throw new Error("BUDGET_REPO_METHOD_MISSING");
    }

    const deleted = await this.budgetRepo.deleteByIdForUser(budgetId, userId);

    if (!deleted) {
      const err = new Error("BUDGET_NOT_FOUND");
      err.statusCode = 404;
      throw err;
    }

    return deleted;
  }
}

module.exports = DeleteBudget;