class TransactionRepository {
  async create(txEntity) {
    throw new Error("Not implemented");
  }

  async findByUserId(userId, opts = {}) {
    throw new Error("Not implemented");
  }
}

module.exports = { TransactionRepository };
