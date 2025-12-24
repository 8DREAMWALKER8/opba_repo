// routes/notificationRoutes.js
const express = require("express");
const router = express.Router();

const notificationController = require("../controllers/notificationController");
const { protect } = require("../middleware/authMiddleware");

// Kullanıcının tüm bildirimlerini getir
router.get("/", protect, notificationController.getMyNotifications);

// Tek bir bildirimi okundu işaretle
router.patch("/:id/read", protect, notificationController.markNotificationAsRead);

// Tüm bildirimleri okundu işaretle
router.patch(
  "/mark-all/read",
  protect,
  notificationController.markAllAsRead
);

// TEST için bildirim oluştur (isterseniz sonra silebilirsiniz)
router.post("/", protect, notificationController.createNotification);

module.exports = router;
