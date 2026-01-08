class GetMyTransactions {
  constructor(transactionRepo) {
    this.transactionRepo = transactionRepo;
  }

  async execute({ userId, limit, skip, type, category, accountId }) {
    console.log("usecase HIT accountId =", accountId);
    return await this.transactionRepo.findByUserId(userId, { limit, skip, type, category, accountId });
  }
}

module.exports = GetMyTransactions;
