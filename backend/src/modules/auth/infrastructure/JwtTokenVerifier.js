const jwt = require("jsonwebtoken");

class JwtTokenVerifier {
  verify(token) {
    const secret = process.env.JWT_SECRET;
    if (!secret) throw new Error("JWT_SECRET_MISSING");

    // throws if invalid/expired
    return jwt.verify(token, secret);
  }
}

module.exports = { JwtTokenVerifier };
