// Kullanıcıya ait bir işlemi siler ve silinen işlemin etkisini
// ilgili banka hesabının bakiyesinden geri alarak günceller.

class DeleteTransaction {
  constructor(transactionRepo, bankAccountRepo) {
    this.transactionRepo = transactionRepo;
    this.bankAccountRepo = bankAccountRepo;
  }

  async execute({ userId, transactionId }) {
    if (!transactionId) throw new Error("TRANSACTION_ID_REQUIRED");

    const existing = await this.transactionRepo.findByIdForUser(
      transactionId,
      userId
    );
    if (!existing) throw new Error("TRANSACTION_NOT_FOUND");

    const accountId = existing.accountId;
    if (!accountId) throw new Error("ACCOUNT_ID_REQUIRED");

    const account = await this.bankAccountRepo.findByUserId(
      accountId,
      userId
    );
    if (!account) throw new Error("ACCOUNT_NOT_FOUND");

    const amt = Number(existing.amount) || 0;

    const delta = existing.type === "income" ? -amt : +amt;


    await this.bankAccountRepo.incBalanceByIdForUser(accountId, userId, delta);

    const deleted = await this.transactionRepo.deleteByIdForUser(
      transactionId,
      userId
    );

    if (!deleted) throw new Error("TRANSACTION_NOT_FOUND");

    return deleted;
  }
}

module.exports = DeleteTransaction;