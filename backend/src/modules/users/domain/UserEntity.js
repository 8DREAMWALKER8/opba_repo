// User domain nesnesi; kullanıcı bilgilerini ve temel doğrulamaları tek yerde toplar

class UserEntity {
  constructor({
    id,
    username,
    email,
    phone,
    language = "tr",
    theme = "light",
    currency = "TRY",
  }) {
    this.id = id;
    this.username = username;
    this.email = email;

    if (phone != null) {
      if (typeof phone !== "string") throw new Error("PHONE_INVALID");
      const digitsOnly = /^\d{10,15}$/;
      if (!digitsOnly.test(phone)) throw new Error("PHONE_INVALID_FORMAT");
      this.phone = phone;
    } else {
      this.phone = null;
    }

    this.language = language;
    this.theme = theme;
    this.currency = currency;
  }
}

module.exports = { UserEntity };
