class BudgetEntity {
  constructor({ userId, category, limitAmount, spentAmount = 0, currency = "TRY" }) {
    this.userId = userId;
    this.category = category;
    this.limitAmount = Number(limitAmount);
    this.spentAmount = Number(spentAmount);
    this.currency = currency;
  }
}

module.exports = BudgetEntity;
