const router = require("express").Router();
const { z } = require("zod");
const crypto = require("crypto");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const User = require("../models/User");

const { PASSWORD_REGEX } = require("../utils/validators");

const M = {
  tr: {
    resetSent: "Doğrulama kodu gönderildi.",
    userNotFound: "Bu e-posta ile kayıtlı kullanıcı bulunamadı.",
    invalidCode: "Kod hatalı.",
    codeExpired: "Kodun süresi doldu.",
    tooManyAttempts: "Çok fazla deneme yapıldı. Lütfen tekrar deneyin.",
    passwordMismatch: "Şifreler eşleşmiyor.",
    passwordUpdated: "Şifre başarıyla güncellendi.",
    resetTokenInvalid: "Reset token geçersiz veya süresi dolmuş.",
    jwtSecretMissing: "JWT_SECRET eksik. .env dosyanı kontrol et.",
    sameAsOldPassword: "Yeni şifre mevcut şifreyle aynı olamaz.",
  },
  en: {
    resetSent: "Verification code sent.",
    userNotFound: "No user found with this email.",
    invalidCode: "Invalid code.",
    codeExpired: "Code expired.",
    tooManyAttempts: "Too many attempts. Please try again later.",
    passwordMismatch: "Passwords do not match.",
    passwordUpdated: "Password updated successfully.",
    resetTokenInvalid: "Reset token is invalid or expired.",
    jwtSecretMissing: "JWT_SECRET is missing. Check your .env file.",
    sameAsOldPassword: "New password cannot be the same as the current password.",
  },
};

function getLang(req) {
  return req.query.lang === "en" ? "en" : "tr";
}

function sha256(text) {
  return crypto.createHash("sha256").update(text).digest("hex");
}

// 1) Şifremi unuttum → kod üret
// POST /auth/forgot-password?lang=tr|en
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

// 2) Kod doğrula → resetToken üret
// POST /auth/verify-reset-code?lang=tr|en
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

// 3) Şifre sıfırla (passwordHash güncellenir)
// POST /auth/reset-password?lang=tr|en
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
  // Zod validation hatası
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
