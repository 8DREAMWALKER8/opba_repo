/**
 * User Domain Entity
 * Framework ve DB'den tamamen bağımsızdır
 */
class UserEntity {
  constructor({
    id,
    username,
    email,
    phone,
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

    if (phone !== undefined && phone !== null) {
      if (typeof phone !== "string") {
        throw new Error("phone must be a string");
      }
      const normalizedPhone = phone.trim();
      if (!/^\d{10,15}$/.test(normalizedPhone)) {
        throw new Error("phone must be digits (10-15)");
      }
      this.phone = normalizedPhone;
    } else {
      this.phone = undefined;
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