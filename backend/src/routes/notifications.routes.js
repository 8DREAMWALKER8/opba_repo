/**
 * Bu dosya, kullanıcıya ait bildirimleri yönetir.
 * Bildirimleri listeler.
 * Okundu / okunmadı durumunu yönetir.
 * Uyarı ve bilgilendirme mesajlarını gösterir.
 */

const router = require("express").Router();
const { z } = require("zod");
const { requireAuth } = require("../middleware/auth");
const Notification = require("../models/Notification");

// Bildirim Listeleme
// Kullanıcının tüm bildirimlerini listeler.
// isRead parametresi ile okundu / okunmadı filtrelenebilir.
// page & limit ile sayfalama yapılır.
router.get("/", requireAuth, async (req, res) => {
  const { isRead, page = "1", limit = "20" } = req.query;

  const filter = { userId: req.user.userId };
  if (isRead === "true") filter.isRead = true;
  if (isRead === "false") filter.isRead = false;

  const pageNum = Math.max(1, parseInt(page, 10) || 1);
  const limitNum = Math.min(100, Math.max(1, parseInt(limit, 10) || 20));
  const skip = (pageNum - 1) * limitNum;

  const [items, total, unreadCount] = await Promise.all([
    Notification.find(filter).sort({ createdAt: -1 }).skip(skip).limit(limitNum),
    Notification.countDocuments(filter),
    Notification.countDocuments({ userId: req.user.userId, isRead: false }),
  ]);

  res.json({
    ok: true,
    page: pageNum,
    limit: limitNum,
    total,
    unreadCount,
    items,
  });
});
// Tek Bildirimi Okundu Yapma
// PATCH /notifications/:id/read
// Seçilen bildirimi okundu olarak işaretler.
router.patch("/:id/read", requireAuth, async (req, res) => {
  const { id } = req.params;

  const updated = await Notification.findOneAndUpdate(
    { _id: id, userId: req.user.userId },
    { $set: { isRead: true } },
    { new: true }
  );

  if (!updated) {
    return res.status(404).json({ ok: false, message: "Notification not found" });
  }

  res.json({ ok: true, notification: updated });
});
// Tüm Bildirimleri Okundu Yapma
// PATCH /notifications/mark-all/read
// Kullanıcının tüm okunmamış bildirimlerini okundu yapar.
router.patch("/mark-all/read", requireAuth, async (req, res) => {
  const result = await Notification.updateMany(
    { userId: req.user.userId, isRead: false },
    { $set: { isRead: true } }
  );

  res.json({
    ok: true,
    matched: result.matchedCount ?? result.n,
    modified: result.modifiedCount ?? result.nModified,
  });
});
//Test Amaçlı Bildirim Oluşturma
// POST /notifications  (TEST için bildirim oluşturma)
// Test ve geliştirme amaçlı manuel bildirim ekler.
router.post("/", requireAuth, async (req, res) => {
  const schema = z.object({
    title: z.string().min(2),
    body: z.string().optional(),
    type: z.enum(["monthly_summary", "limit_exceeded", "goal_reached", "general"]).optional(),
  });

  const data = schema.parse(req.body);

  const created = await Notification.create({
    userId: req.user.userId,
    title: data.title,
    body: data.body || "",
    type: data.type || "general",
    isRead: false,
  });

  res.status(201).json({ ok: true, notification: created });
});

module.exports = router;
