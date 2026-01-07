class GetBudgets {
  constructor({ budgetRepo }) {
    this.budgetRepo = budgetRepo;
  }

  async execute({ userId }) {
    if (!userId) throw new Error("USER_ID_REQUIRED");
    const budgets = await this.budgetRepo.findByUser(userId);
    return budgets;
  }
}

module.exports = GetBudgets;
