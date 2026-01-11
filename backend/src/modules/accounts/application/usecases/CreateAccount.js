/**
 * Girişiriş yapmış kullanıcıya ait yeni bir banka hesabı oluşturmak için kullanılır.
 * Controller’dan gelen doğrulanmış veriyi alır ve 
 * veritabanına kaydetme işlemini repository katmanına devreder.
 */

class CreateAccount {
  constructor({ repo }) {
    this.repo = repo;
  }
  async execute({ userId, data }) {
    return this.repo.createForUser(userId, data);
  }
}
module.exports = CreateAccount;
