const router = require("express").Router();
const { z } = require("zod");
const { requireAuth } = require("../middleware/auth");
const Notification = require("../models/Notification");

// GET /notifications?isRead=true|false&page=1&limit=20
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

// PATCH /notifications/:id/read
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

// PATCH /notifications/mark-all/read
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

// POST /notifications  (TEST için bildirim oluşturma)
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
