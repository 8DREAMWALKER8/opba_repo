// CreateTransaction.js
const TransactionEntity = require("../../domain/TransactionEntity");

class CreateTransaction {
  constructor(transactionRepo, budgetRepo, notificationRepo) {
    this.transactionRepo = transactionRepo;
    this.budgetRepo = budgetRepo;
    this.notificationRepo = notificationRepo;
  }

  async execute({ userId, amount, category, description, type, currency, occurredAt }) {
    const entity = new TransactionEntity({
      userId,
      amount,
      category,
      description,
      type,
      currency,
      occurredAt: occurredAt ? new Date(occurredAt) : new Date(),
    });

    const created = await this.transactionRepo.create(entity);

    // sadece expense budget'i etkiler
    if (created.type !== "expense") return created;
    if (!created.category) return created;

    const txDate = created.occurredAt ? new Date(created.occurredAt) : new Date();
    const month = txDate.getMonth() + 1;
    const year = txDate.getFullYear();

    const budget = await this.budgetRepo.findActiveByUserAndCategory(
      userId,
      created.category,
      month,
      year
    );
    if (!budget) return created;

    const { from, to } = this._getMonthlyRange(txDate);
    const usedCurrency = created.currency || currency || "TRY";

    const spent = await this.transactionRepo.sumExpensesByUserAndCategoryBetween(
      userId,
      created.category,
      from,
      to,
      usedCurrency
    );

    const limit = Number(budget.limit);

    if (Number.isFinite(limit) && spent > limit) {
      await this.notificationRepo.create({
        userId,
        type: "BUDGET_EXCEEDED",
        title: "Bütçe limiti aşıldı",
        message: `${created.category} bütçesi aşıldı. Limit: ${limit} ${usedCurrency}, Harcama: ${spent} ${usedCurrency}`,
        meta: {
          category: created.category,
          budgetId: budget._id,
          limit,
          spent,
          month,
          year,
        },
      });
    }

    return created;
  }

  _getMonthlyRange(date) {
    const d = new Date(date);
    const from = new Date(d.getFullYear(), d.getMonth(), 1, 0, 0, 0, 0);
    const to = new Date(d.getFullYear(), d.getMonth() + 1, 1, 0, 0, 0, 0);
    return { from, to };
  }
}

module.exports = CreateTransaction;
