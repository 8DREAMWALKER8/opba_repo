/**
 * Bu sınıf, kullanıcıya ait bir banka hesabını
 * sistemden silmeden pasif hale getirmek için kullanılır.
 * Hesap bulunamazsa veya kullanıcıya ait değilse 404 hatası fırlatır.
 */

class DeactivateAccount {
  constructor({ repo }) {
    this.repo = repo;
  }
  async execute({ userId, accountId }) {
    const updated = await this.repo.deactivate(userId, accountId);
    if (!updated) {
      const err = new Error("ACCOUNT_NOT_FOUND");
      err.status = 404;
      throw err;
    }
    return updated;
  }
}
module.exports = DeactivateAccount;
