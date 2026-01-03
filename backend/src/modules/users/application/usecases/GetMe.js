class GetMe {
  constructor({ userRepo }) {
    this.userRepo = userRepo;
  }

  async execute({ userId }) {
    const user = await this.userRepo.findById(userId);
    if (!user) throw new Error("USER_NOT_FOUND");

    return {
      id: user._id.toString(),
      username: user.username,
      email: user.email,
      securityQuestionId: user.securityQuestionId,
    };
  }
}

module.exports = { GetMe };
