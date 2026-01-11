// Bir transaction nesnesini temsil eder.
// Constructor içinde gerekli alanların doğru gelip gelmediği kontrol edilir ve geçersizse hata fırlatılır.

class TransactionEntity {
  constructor({
    userId,
    accountId,
    amount,
    category,
    description,
    type,
    currency = "TRY",
    occurredAt = new Date(),
  }) {
    if (!userId) throw new Error("USER_ID_REQUIRED");
    if (!accountId) throw new Error("ACCOUNT_ID_REQUIRED");

    if (typeof amount !== "number" || !Number.isFinite(amount) || amount <= 0) {
      throw new Error("AMOUNT_INVALID");
    }

    if (!category || typeof category !== "string") {
      throw new Error("CATEGORY_REQUIRED");
    }

    if (!type || !["expense", "income"].includes(type)) {
      throw new Error("TYPE_INVALID");
    }

    this.userId = userId;
    this.accountId = accountId;
    this.amount = amount;
    this.category = category;
    this.description = description || "";
    this.type = type;
    this.currency = currency;
    this.occurredAt = occurredAt;
  }
}

module.exports = TransactionEntity;
