// DeleteTransaction.js
class DeleteTransaction {
  constructor(transactionRepo, bankAccountRepo) {
    this.transactionRepo = transactionRepo;
    this.bankAccountRepo = bankAccountRepo;
  }

  async execute({ userId, transactionId }) {
    if (!transactionId) throw new Error("TRANSACTION_ID_REQUIRED");

    // 1) Transaction user'a ait mi?
    const existing = await this.transactionRepo.findByIdForUser(
      transactionId,
      userId
    );
    if (!existing) throw new Error("TRANSACTION_NOT_FOUND");

    const accountId = existing.accountId;
    if (!accountId) throw new Error("ACCOUNT_ID_REQUIRED");

    // 2) Account aktif mi / user'a ait mi?
    const account = await this.bankAccountRepo.findByUserId(
      accountId,
      userId
    );
    if (!account) throw new Error("ACCOUNT_NOT_FOUND");

    // 3) Balance revert (silinen işlemin ters etkisi)
    const amt = Number(existing.amount) || 0;

    // existing.type: income -> +amt demekti, silince -amt
    // existing.type: expense -> -amt demekti, silince +amt
    const delta = existing.type === "income" ? -amt : +amt;

    // Negatif bakiyeye düşme kontrolü istersen burada:
    // if (delta < 0 && (Number(account.balance) || 0) < Math.abs(delta)) throw new Error("INSUFFICIENT_BALANCE");

    await this.bankAccountRepo.incBalanceByIdForUser(accountId, userId, delta);

    // 4) Transaction sil
    const deleted = await this.transactionRepo.deleteByIdForUser(
      transactionId,
      userId
    );

    if (!deleted) throw new Error("TRANSACTION_NOT_FOUND");

    return deleted;
  }
}

module.exports = DeleteTransaction;