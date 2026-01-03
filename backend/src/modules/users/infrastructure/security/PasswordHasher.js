const bcrypt = require("bcryptjs");

class PasswordHasher {
  async hash(raw) {
    const salt = await bcrypt.genSalt(10);
    return bcrypt.hash(raw, salt);
  }

  async compare(raw, hashed) {
    return bcrypt.compare(raw, hashed);
  }
}

module.exports = { PasswordHasher };
