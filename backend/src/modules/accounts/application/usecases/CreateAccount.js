class CreateAccount {
  constructor({ repo }) {
    this.repo = repo;
  }
  async execute({ userId, data }) {
    return this.repo.createForUser(userId, data);
  }
}
module.exports = CreateAccount;
