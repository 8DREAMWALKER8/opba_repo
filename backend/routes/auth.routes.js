/**
 * Bu dosya, kullanıcı kimlik doğrulama işlemlerini yönetir.
 * Kullanıcı kayıt olur.
 * 2 aşamalı giriş (şifre + güvenlik sorusu)
 * JWT token üretilir.
 */

const router = require("express").Router();
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { z } = require("zod");

const User = require("../models/User");
const { SECURITY_QUESTIONS, getQuestionText } = require("../utils/securityQuestions");
const { PASSWORD_REGEX } = require("../utils/validators");


function zodErrorMessage(err) {
  if (err && Array.isArray(err.issues) && err.issues.length > 0) {
    return err.issues[0].message;
  }
  if (err && Array.isArray(err.errors) && err.errors.length > 0) {
    return err.errors[0].message;
  }
  return null;
}

// Frontend'deki dropdown için güvenlik sorularını döndürür.
// Sadece id ve görünen metin (TR) gönderilir.
router.get("/security-questions", (req, res) => {
  res.json({
    ok: true,
    questions: SECURITY_QUESTIONS.map((q) => ({
      id: q.id,
      text: q.tr,
    })),
  });
});

// REGISTER
// POST /auth/register
// Yeni kullanıcı oluşturur.
router.post("/register", async (req, res) => {
  const schema = z
    .object({
      username: z.string().min(3, "Kullanıcı adı en az 3 karakter olmalı"),
      email: z.string().email("Geçerli bir e-posta girin"),
      phone: z.string().min(10, "Telefon numarası geçersiz"),

      password: z.string().min(8, "Şifre en az 8 karakter olmalı"),
      passwordConfirm: z.string().min(8, "Şifre tekrar gerekli"),

      securityQuestionId: z.string().min(1, "Güvenlik sorusu seçin"),
      securityAnswer: z.string().min(1, "Güvenlik sorusu cevabı gerekli"),
    })
    .refine((val) => val.password === val.passwordConfirm, {
      message: "Şifreler uyuşmuyor",
      path: ["passwordConfirm"],
    });

  let data;
  try {
    data = schema.parse(req.body);
  } catch (err) {
    const msg = zodErrorMessage(err);
    return res.status(400).json({ ok: false, message: msg || "Geçersiz istek" });
  }

  if (!PASSWORD_REGEX.test(data.password)) {
    return res.status(400).json({
      ok: false,
      message:
        "Şifre en az 8 karakter olmalı; büyük harf, küçük harf ve özel karakter içermelidir.",
    });
  }


  const qText = getQuestionText(data.securityQuestionId, "tr");
  if (!qText) {
    return res.status(400).json({ ok: false, message: "Invalid securityQuestionId" });
  }

  const normalizedEmail = data.email.toLowerCase().trim();

  const exists = await User.findOne({
    $or: [{ username: data.username }, { email: normalizedEmail }],
  });

  if (exists) {
    return res.status(409).json({ ok: false, message: "Username or email already exists" });
  }

  const passwordHash = await bcrypt.hash(data.password, 10);
  const securityAnswerHash = await bcrypt.hash(data.securityAnswer, 10);

  const user = await User.create({
    username: data.username,
    email: normalizedEmail,
    phone: data.phone,
    passwordHash,
    securityQuestionId: data.securityQuestionId,
    securityAnswerHash,
  });

  return res.status(201).json({ ok: true, userId: user._id });
});

  // Login(Şifre Kontrolü)
  // POST /auth/login
  // Kullanıcı adı + şifre doğru mu kontrol edilir.
router.post("/login", async (req, res) => {
  const schema = z.object({
    email: z.string().email("Geçerli bir e-posta girin"),
    password: z.string().min(1, "Şifre gerekli"),
  });

  let data;
  try {
    data = schema.parse(req.body);
  } catch (err) {
    const msg = zodErrorMessage(err);
    return res.status(400).json({ ok: false, message: msg || "Geçersiz istek" });
  }

  const normalizedEmail = data.email.toLowerCase().trim();

  const user = await User.findOne({ email: normalizedEmail });
  if (!user) {
    return res.status(401).json({ ok: false, message: "Invalid credentials" });
  }

  const passOk = await bcrypt.compare(data.password, user.passwordHash);
  if (!passOk) {
    return res.status(401).json({ ok: false, message: "Invalid credentials" });
  }

  if (!process.env.JWT_SECRET) {
    return res.status(500).json({ ok: false, message: "JWT_SECRET missing" });
  }

  const challengeToken = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, {
    expiresIn: "5m",
  });

  const questionText = getQuestionText(user.securityQuestionId, user.language || "tr");

  return res.json({
    ok: true,
    challengeToken,
    securityQuestionId: user.securityQuestionId,
    securityQuestionText: questionText,
  });
});

 // Login(Güvenlik Sorusu)
 // POST /auth/login/verify-question
 // Güvenlik sorusu cevabı doğrulanır.
router.post("/login/verify-question", async (req, res) => {
  const schema = z.object({
    challengeToken: z.string().min(1, "challengeToken gerekli"),
    securityAnswer: z.string().min(1, "Güvenlik cevabı gerekli"),
  });

  let data;
  try {
    data = schema.parse(req.body);
  } catch (err) {
    const msg = zodErrorMessage(err);
    return res.status(400).json({ ok: false, message: msg || "Geçersiz istek" });
  }

  if (!process.env.JWT_SECRET) {
    return res.status(500).json({ ok: false, message: "JWT_SECRET missing" });
  }

  let payload;
  try {
    payload = jwt.verify(data.challengeToken, process.env.JWT_SECRET);
  } catch {
    return res.status(401).json({ ok: false, message: "Challenge expired or invalid" });
  }

  const user = await User.findById(payload.userId);
  if (!user) return res.status(401).json({ ok: false, message: "User not found" });

  const answerOk = await bcrypt.compare(data.securityAnswer, user.securityAnswerHash);
  if (!answerOk) return res.status(401).json({ ok: false, message: "Wrong answer" });

  const accessToken = jwt.sign(
    { userId: user._id, email: user.email },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || "7d" }
  );

  return res.json({ ok: true, accessToken });
});

module.exports = router;
