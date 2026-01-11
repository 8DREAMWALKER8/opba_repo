/**
 * Bu sınıf, JWT access token’ların doğrulanmasından sorumludur.
 * Token doğrulama işlemini jsonwebtoken kütüphanesi ile yapar
 * ve gizli anahtarı (JWT_SECRET) ortam değişkeninden alır.
 * Bu sınıf sadece teknik doğrulamayı yapar, iş mantığı içermez.
 */

const jwt = require("jsonwebtoken");

class JwtTokenVerifier {
  verify(token) {
    const secret = process.env.JWT_SECRET;
    if (!secret) throw new Error("JWT_SECRET_MISSING");

    return jwt.verify(token, secret);
  }
}

module.exports = { JwtTokenVerifier };
