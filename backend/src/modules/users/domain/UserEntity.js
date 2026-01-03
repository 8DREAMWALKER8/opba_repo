/**
 * User Domain Entity
 * Framework ve DB'den tamamen bağımsızdır
 */
class UserEntity {
  constructor({
    id,
    username,
    email,
    passwordHash,
    securityQuestionId,
    securityAnswerHash,
    createdAt = new Date(),
    updatedAt = new Date(),
  }) {
    if (!username || typeof username !== "string") {
      throw new Error("username is required");
    }

    if (!email || typeof email !== "string") {
      throw new Error("email is required");
    }

    this.id = id;
    this.username = username;
    this.email = email.toLowerCase();
    this.passwordHash = passwordHash;
    this.securityQuestionId = securityQuestionId;
    this.securityAnswerHash = securityAnswerHash;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
  }
}

module.exports = { UserEntity };
