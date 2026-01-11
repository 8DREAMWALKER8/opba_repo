const router = require("express").Router();
const { z } = require("zod");
const crypto = require("crypto");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const User = require("../models/User");
const { t } = require("../shared/content");

const { PASSWORD_REGEX } = require("../utils/validators");

const M = {
  resetSent: "errors.RESET_SENT",
  userNotFound: "errors.RESET_USER_NOT_FOUND",
  invalidCode: "errors.RESET_INVALID_CODE",
  codeExpired: "errors.RESET_CODE_EXPIRED",
  tooManyAttempts: "errors.RESET_TOO_MANY_ATTEMPTS",
  passwordMismatch: "errors.RESET_PASSWORD_MISMATCH",
  passwordUpdated: "errors.PASSWORD_UPDATED",
  resetTokenInvalid: "errors.RESET_TOKEN_INVALID",
  jwtSecretMissing: "errors.JWT_SECRET_MISSING",
  sameAsOldPassword: "errors.RESET_SAME_AS_OLD",
  passwordWeak: "errors.PASSWORD_WEAK",
};

function getLang(req) {
  return req.query.lang === "en" ? "en" : "tr";
}

function msg(req, keyPath) {
  return t(req, keyPath, keyPath);
}

function sha256(text) {
  return crypto.createHash("sha256").update(text).digest("hex");

}

// Kullanıcı e-postası ile 6 haneli doğrulama kodu oluşturur.
router.post("/forgot-password", async (req, res) => {
  const lang = getLang(req);

  const schema = z.object({
    email: z.string().email(),
  });

  const { email } = schema.parse(req.body);

  const user = await User.findOne({ email: email.toLowerCase().trim() });
  if (!user) {
    return res.status(404).json({ ok: false, message: M[lang].userNotFound });
  }

  const code = String(Math.floor(100000 + Math.random() * 900000));

  user.resetCodeHash = sha256(code);
  user.resetCodeExpiresAt = new Date(Date.now() + 10 * 60 * 1000);
  user.resetCodeAttempts = 0;
  await user.save();

  return res.json({
    ok: true,
    message: M[lang].resetSent,
    devCode: code,
  });
});


// Kullanıcının girdiği kodu kontrol eder.
router.post("/verify-reset-code", async (req, res) => {
  const lang = getLang(req);

  const schema = z.object({
    email: z.string().email(),
    code: z.string().regex(/^\d{6}$/),
  });

  const { email, code } = schema.parse(req.body);

  const user = await User.findOne({ email: email.toLowerCase().trim() });
  if (!user) {
    return res.status(404).json({ ok: false, message: M[lang].userNotFound });
  }

  if (!user.resetCodeHash || !user.resetCodeExpiresAt) {
    return res.status(400).json({ ok: false, message: M[lang].invalidCode });
  }

  if (user.resetCodeAttempts >= 5) {
    return res.status(429).json({ ok: false, message: M[lang].tooManyAttempts });
  }

  if (user.resetCodeExpiresAt.getTime() < Date.now()) {
    return res.status(400).json({ ok: false, message: M[lang].codeExpired });
  }

  const ok = sha256(code) === user.resetCodeHash;
  if (!ok) {
    user.resetCodeAttempts += 1;
    await user.save();
    return res.status(400).json({ ok: false, message: M[lang].invalidCode });
  }

  if (!process.env.JWT_SECRET) {
    return res.status(500).json({ ok: false, message: M[lang].jwtSecretMissing });
  }

  const resetToken = jwt.sign(
    { userId: user._id.toString(), purpose: "password_reset" },
    process.env.JWT_SECRET,
    { expiresIn: "15m" }
  );

  return res.json({ ok: true, resetToken });
});

// Yeni şifre belirlenir ve passwordHash güncellenir.
router.post("/reset-password", async (req, res) => {
  const lang = getLang(req);


  const schema = z.object({
    resetToken: z.string().min(10),
    password: z.string().min(8),
    passwordConfirm: z.string().min(8),
  });

  let resetToken, password, passwordConfirm;

try {
  ({ resetToken, password, passwordConfirm } = schema.parse(req.body));
} catch (err) {

  return res.status(400).json({
    ok: false,
    message:
      "Geçersiz istek. Şifre en az 8 karakter olmalı; büyük harf, küçük harf ve özel karakter içermelidir.",
  });
}



  if (!PASSWORD_REGEX.test(password)) {
    return res.status(400).json({
      ok: false,
      message:
        "Şifre en az 8 karakter olmalı; büyük harf, küçük harf ve özel karakter içermelidir.",
    });
  }

  if (password !== passwordConfirm) {
    return res.status(400).json({ ok: false, message: M[lang].passwordMismatch });
  }

  if (!process.env.JWT_SECRET) {
    return res.status(500).json({ ok: false, message: M[lang].jwtSecretMissing });
  }

  let payload;
  try {
    payload = jwt.verify(resetToken, process.env.JWT_SECRET);
  } catch {
    return res.status(401).json({ ok: false, message: M[lang].resetTokenInvalid });
  }

  if (!payload || payload.purpose !== "password_reset") {
    return res.status(401).json({ ok: false, message: M[lang].resetTokenInvalid });
  }

  const user = await User.findById(payload.userId);
  if (!user) {
    return res.status(404).json({ ok: false, message: M[lang].userNotFound });
  }

 
  const isSameAsOld = await bcrypt.compare(password, user.passwordHash);
  if (isSameAsOld) {
    return res.status(400).json({ ok: false, message: M[lang].sameAsOldPassword });
  }

  // passwordHash güncelle
  user.passwordHash = await bcrypt.hash(password, 10);

  // reset state temizle
  user.resetCodeHash = null;
  user.resetCodeExpiresAt = null;
  user.resetCodeAttempts = 0;

  await user.save();

  return res.json({ ok: true, message: M[lang].passwordUpdated });
});

module.exports = router;
