class DeactivateAccount {
  constructor({ repo }) {
    this.repo = repo;
  }
  async execute({ userId, accountId }) {
    const updated = await this.repo.deactivate(userId, accountId);
    if (!updated) {
      const err = new Error("Account not found");
      err.status = 404;
      throw err;
    }
    return updated;
  }
}
module.exports = DeactivateAccount;
