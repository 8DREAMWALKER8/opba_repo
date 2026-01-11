/**
 * Bu sınıf, istemciden gelen erişim token’ını doğrulamak için kullanılır.
 * Token’ın varlığını ve geçerliliğini kontrol eder.
 * Geçersiz veya eksik token durumunda hata fırlatır.
 */

class VerifyAccessToken {
  constructor({ tokenVerifier }) {
    this.tokenVerifier = tokenVerifier;
  }

  async execute({ token }) {
    if (!token) throw new Error("AUTH_TOKEN_MISSING");

    let payload;
    try {
      payload = this.tokenVerifier.verify(token);
    } catch (e) {
      throw new Error("AUTH_TOKEN_INVALID");
    }

    // bizim payload: { userId: "..." }
    if (!payload?.userId) throw new Error("AUTH_TOKEN_INVALID");

    return { userId: payload.userId };
  }
}

module.exports = { VerifyAccessToken };
