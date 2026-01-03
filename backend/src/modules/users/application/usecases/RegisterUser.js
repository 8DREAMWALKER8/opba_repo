class RegisterUser {
  constructor({ userRepo, hasher }) {
    this.userRepo = userRepo;
    this.hasher = hasher;
  }

  async execute({
    username,
    email,
    phone,
    password,
    securityQuestionId,
    securityAnswer,
  }) {
    const existingEmail = await this.userRepo.findByEmail(email);
    if (existingEmail) throw new Error("EMAIL_EXISTS");

    const existingUsername = await this.userRepo.findByUsername(username);
    if (existingUsername) throw new Error("USERNAME_EXISTS");

    const passwordHash = await this.hasher.hash(password);
    const securityAnswerHash = await this.hasher.hash(securityAnswer);

    const user = await this.userRepo.create({
      username,
      email: email.toLowerCase(),
      phone,
      passwordHash,
      securityQuestionId,
      securityAnswerHash,
    });

    return {
      id: user._id.toString(),
      username: user.username,
      email: user.email,
    };
  }
}

module.exports = { RegisterUser };
