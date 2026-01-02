class TransactionEntity {
  constructor({
    userId,
    amount,
    category,
    description,
    type,
    currency = "TRY",
    occurredAt = new Date(),
  }) {
    if (!userId) throw new Error("userId is required");
    if (typeof amount !== "number" || !Number.isFinite(amount) || amount <= 0) {
      throw new Error("amount must be a positive number");
    }
    if (!category || typeof category !== "string") {
      throw new Error("category is required");
    }
    if (!["expense", "income"].includes(type)) {
      throw new Error("type must be 'expense' or 'income'");
    }

    this.userId = userId;
    this.amount = amount;
    this.category = category;
    this.description = description || "";
    this.type = type;
    this.currency = currency;
    this.occurredAt = occurredAt;
  }
}

module.exports = TransactionEntity;
