budgetRepository

class BudgetRepository {
  async findByUser(userId) { throw new Error("NOT_IMPLEMENTED"); }
  async upsertBudget(userId, data) { throw new Error("NOT_IMPLEMENTED"); }
  async findActiveByUserAndCategory(userId, category, month, year) { throw new Error("NOT_IMPLEMENTED"); }
}
module.exports = BudgetRepository;
