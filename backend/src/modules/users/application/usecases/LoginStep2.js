class LoginStep2 {
  constructor({ userRepo, hasher, tokenService }) {
    this.userRepo = userRepo;
    this.hasher = hasher;
    this.tokenService = tokenService;
  }

  async execute({ userId, securityAnswer }) {
    const user = await this.userRepo.findById(userId);
    if (!user) throw new Error("USER_NOT_FOUND");

    const ok = await this.hasher.compare(securityAnswer, user.securityAnswerHash);
    if (!ok) throw new Error("SECURITY_ANSWER_INVALID");

    const token = this.tokenService.sign({ userId: user._id.toString() }, { expiresIn: "7d" });

    return {
      token,
      user: { id: user._id.toString(), username: user.username, email: user.email },
    };
  }
}

module.exports = { LoginStep2 };
