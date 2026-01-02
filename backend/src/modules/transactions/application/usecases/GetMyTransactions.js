class GetMyTransactions {
  constructor(transactionRepo) {
    this.transactionRepo = transactionRepo;
  }

  async execute({ userId, limit, skip, type, category }) {
    return await this.transactionRepo.findByUserId(userId, { limit, skip, type, category });
  }
}

module.exports = GetMyTransactions;
