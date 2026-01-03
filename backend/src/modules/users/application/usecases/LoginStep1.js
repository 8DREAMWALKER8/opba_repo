class LoginStep1 {
  constructor({ userRepo, hasher }) {
    this.userRepo = userRepo;
    this.hasher = hasher;
  }

  async execute({ email, password }) {
    const user = await this.userRepo.findByEmail(email);
    if (!user) throw new Error("INVALID_CREDENTIALS");

    const ok = await this.hasher.compare(password, user.passwordHash);
    if (!ok) throw new Error("INVALID_CREDENTIALS");

    return {
      userId: user._id.toString(),
      securityQuestionId: user.securityQuestionId,
    };
  }
}

module.exports = { LoginStep1 };
