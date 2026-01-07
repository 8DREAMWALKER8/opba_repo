const jwt = require("jsonwebtoken");

class TokenService {
  sign(payload, { expiresIn = "7d" } = {}) {
    const secret = process.env.JWT_SECRET;
    if (!secret) throw new Error("JWT_SECRET_MISSING");
    return jwt.sign(payload, secret, { expiresIn });
  }
}

module.exports = { TokenService };
