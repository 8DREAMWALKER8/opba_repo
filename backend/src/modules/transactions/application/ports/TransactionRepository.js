// İşlemler için veritabanı işlemlerinin nasıl yapılacağını tanımlayan bir repository arayüzüdür.
// Gerçek create ve listeleme işlemleri infrastructure katmanında yazılır.

class TransactionRepository {
  async create(txEntity) {
    throw new Error("NOT_IMPLEMENTED");
  }

  async findByUserId(userId, opts = {}) {
    throw new Error("NOT_IMPLEMENTED");
  }
}

module.exports = { TransactionRepository };
