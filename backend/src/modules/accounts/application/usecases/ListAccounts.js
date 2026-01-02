class ListAccounts {
  constructor({ repo }) {
    this.repo = repo;
  }
  async execute({ userId }) {
    return this.repo.listActiveByUser(userId);
  }
}
module.exports = ListAccounts;
