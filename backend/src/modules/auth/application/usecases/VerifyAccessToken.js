/**
  istemciden gelen erişim token’ını doğrulamak için kullanılır.
  token’ın varlığını ve geçerliliğini kontrol eder. geçersiz veya eksik token durumunda hata fırlatır.
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

    if (!payload?.userId) throw new Error("AUTH_TOKEN_INVALID");

    return { userId: payload.userId };
  }
}

module.exports = { VerifyAccessToken };
