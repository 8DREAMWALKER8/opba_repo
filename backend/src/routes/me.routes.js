/**
 * Bu dosya, giriş yapan kullanıcının kendi profil/ayar işlemlerini yönetir.
 * Hepsinde requireAuth var çünkü sadece oturum açan kullanıcı erişebilir.
 */
const router = require("express").Router();
const { z, email } = require("zod");
const bcrypt = require("bcryptjs");
const User = require("../models/User");
const { requireAuth } = require("../middleware/auth");
const {
  ALLOWED_CURRENCIES,
  ALLOWED_LANGUAGES,
  normalizeCurrency,
  normalizeLanguage,
} = require("../utils/validators");

function zodErrorMessage(err) {
  if (err && Array.isArray(err.issues) && err.issues.length > 0) {
    return err.issues[0].message;
  }
  if (err && Array.isArray(err.errors) && err.errors.length > 0) {
    return err.errors[0].message;
  }
  return null;
}

/** 
1-Giriş yapan kullanıcı bilgisi
GET /me
Kullanıcının kendi bilgilerini döndürür.
Güvenlik için passwordHash ve securityAnswerHash alanları response'tan çıkarılır.
*/
router.get("/", requireAuth, async (req, res) => {
  const user = await User.findById(req.user.userId).select(
    "-passwordHash -securityAnswerHash"
  );

  if (!user) {
    return res.status(404).json({ ok: false, message: "User not found" });
  }

  res.json({ ok: true, user });
});

/**
2-Ayarları güncelleme
PATCH /me/settings
Sadece allowlist'teki alanlar güncellenir: language, currency, theme
currency ve language normalize edilip izinli listeden kontrol edilir.
*/
router.patch("/settings", requireAuth, async (req, res) => {
  const allowed = ["language", "currency", "theme"];
  const updates = {};

  for (const key of allowed) {
  if (req.body[key] === undefined) continue;

  
  if (key === "currency") {
    const c = normalizeCurrency(req.body.currency);
    if (!ALLOWED_CURRENCIES.includes(c)) {
      return res.status(400).json({
        ok: false,
        message: "Geçersiz para birimi. Sadece TRY, USD, EUR kabul edilir.",
      });
    }
    updates.currency = c;
    continue;
  }

  if (key === "language") {
    const l = normalizeLanguage(req.body.language);
    if (!ALLOWED_LANGUAGES.includes(l)) {
      return res.status(400).json({
        ok: false,
        message: "Geçersiz dil. Sadece tr ve en kabul edilir.",
      });
    }
    updates.language = l;
    continue;
  }

  updates[key] = req.body[key];
}


  const user = await User.findByIdAndUpdate(
  req.user.userId,
  updates,
  { new: true, runValidators: true }
).select("-passwordHash -securityAnswerHash -resetCodeHash");



  if (!user) {
    return res.status(404).json({ ok: false, message: "User not found" });
  }

  res.json({ ok: true, user });
});

/**
3-Profil düzenle
PATCH /me/profile
username ve phone güncellenir.
Zod ile min/max kontrolü var.
*/
router.patch("/profile", requireAuth, async (req, res) => {
  const schema = z.object({
    username: z.string().min(2).max(30).optional(),
    email: z.string().email().optional(),
    phone: z.string().length(10, "Telefon numarası 10 karakter olmalı").optional(),
  });

  let data;

  try {
    data = schema.parse(req.body);
  } 
  catch (err) {
    const msg = zodErrorMessage(err);
    return res.status(400).json({ ok: false, message: msg || "Geçersiz istek" });
  }

  const user = await User.findByIdAndUpdate(
    req.user.userId,
    { $set: data },
    { new: true }
  ).select("-passwordHash -securityAnswerHash");

  if (!user) {
    return res.status(404).json({ ok: false, message: "User not found" });
  }

  res.json({
    ok: true,
    message: "Profile updated",
    user,
  });
});

/**
4-Şifre değiştir
POST /me/change-password
Mevcut şifre doğruysa yeni şifreyi hashleyip kaydeder.
*/
router.post("/change-password", requireAuth, async (req, res) => {
  const schema = z.object({
    currentPassword: z.string().min(1),
    newPassword: z.string().min(6),
    newPasswordConfirm: z.string().min(6),
  });

  const { currentPassword, newPassword, newPasswordConfirm } =
    schema.parse(req.body);

  if (newPassword !== newPasswordConfirm) {
    return res.status(400).json({
      ok: false,
      message: "New passwords do not match",
    });
  }

  const user = await User.findById(req.user.userId).select("passwordHash");
  if (!user) {
    return res.status(404).json({ ok: false, message: "User not found" });
  }

  const isValid = await bcrypt.compare(currentPassword, user.passwordHash);
  if (!isValid) {
    return res.status(400).json({
      ok: false,
      message: "Current password is incorrect",
    });
  }

  user.passwordHash = await bcrypt.hash(newPassword, 10);
  await user.save();

  res.json({
    ok: true,
    message: "Password updated successfully",
  });
});

module.exports = router;
