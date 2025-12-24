const router = require("express").Router();
const { z } = require("zod");
const bcrypt = require("bcryptjs");
const User = require("../models/User");
const { requireAuth } = require("../middleware/auth");
const {
  ALLOWED_CURRENCIES,
  ALLOWED_LANGUAGES,
  normalizeCurrency,
  normalizeLanguage,
} = require("../utils/validators");


/* =========================
   1-Giriş yapan kullanıcı bilgisi
   GET /me
========================= */
router.get("/", requireAuth, async (req, res) => {
  const user = await User.findById(req.user.userId).select(
    "-passwordHash -securityAnswerHash"
  );

  if (!user) {
    return res.status(404).json({ ok: false, message: "User not found" });
  }

  res.json({ ok: true, user });
});

/* =========================
   2-Ayarlar güncelleme
   PATCH /me/settings
   (tema / dil / para birimi)
========================= */
router.patch("/settings", requireAuth, async (req, res) => {
  const allowed = ["language", "currency", "theme"];
  const updates = {};

  for (const key of allowed) {
  if (req.body[key] === undefined) continue;

  // Normalize + allowlist kontrolleri
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

  // theme gibi diğer alanlar
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

/* =========================
   3-Profil düzenle
   PATCH /me/profile
   (ad / telefon)
========================= */
router.patch("/profile", requireAuth, async (req, res) => {
  const schema = z.object({
    username: z.string().min(2).max(30).optional(),
    phone: z.string().min(7).max(20).optional(),
  });

  const data = schema.parse(req.body);

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

/* =========================
   4-Şifre değiştir
   POST /me/change-password
========================= */
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
