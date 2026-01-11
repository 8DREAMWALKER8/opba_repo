class TransactionRepository {
  async create(txEntity) {
    throw new Error("NOT_IMPLEMENTED");
  }

  async findByUserId(userId, opts = {}) {
    throw new Error("NOT_IMPLEMENTED");
  }
}

module.exports = { TransactionRepository };
