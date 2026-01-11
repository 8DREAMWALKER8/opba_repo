/*
  JWT doğrulayıcı ile VerifyAccessToken use case’ini bağlar ve dış katmanlara hazır şekilde sunar.
 */

const { JwtTokenVerifier } = require("./infrastructure/JwtTokenVerifier");
const { VerifyAccessToken } = require("./application/usecases/VerifyAccessToken");

function buildAuthModule() {
  const tokenVerifier = new JwtTokenVerifier();
  const verifyAccessToken = new VerifyAccessToken({ tokenVerifier });

  return { verifyAccessToken };
}

module.exports = { buildAuthModule };
