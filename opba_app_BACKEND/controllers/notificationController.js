// controllers/notificationController.js
const Notification = require("../models/Notification");

// ---- Giriş yapmış kullanıcının bildirimlerini getir ----
// GET /api/notifications
exports.getMyNotifications = async (req, res) => {
  try {
    // Token'dan userId al (hem id hem userId ihtimalini düşünelim)
    const userId = req.user.id || req.user.userId;

    if (!userId) {
      return res
        .status(401)
        .json({ message: "Kullanıcı kimliği bulunamadı (token)." });
    }

    const notifications = await Notification.find({ user: userId })
      .sort({ createdAt: -1 }); // En yeni yukarıda

    return res.status(200).json({
      message: "Bildirimler getirildi.",
      notifications,
    });
  } catch (err) {
    console.error("getMyNotifications error:", err);
    return res
      .status(500)
      .json({ message: "Bildirimler getirilirken bir hata oluştu." });
  }
};

// ---- Tek bir bildirimi okundu işaretle ----
// PATCH /api/notifications/:id/read
exports.markNotificationAsRead = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { id } = req.params;

    const notification = await Notification.findOneAndUpdate(
      { _id: id, user: userId },
      { isRead: true },
      { new: true }
    );

    if (!notification) {
      return res.status(404).json({ message: "Bildirim bulunamadı." });
    }

    return res.status(200).json({
      message: "Bildirim okundu olarak işaretlendi.",
      notification,
    });
  } catch (err) {
    console.error("markNotificationAsRead error:", err);
    return res
      .status(500)
      .json({ message: "Bildirim güncellenirken bir hata oluştu." });
  }
};

// ---- Tüm bildirimleri okundu işaretle ----
// PATCH /api/notifications/mark-all/read
exports.markAllAsRead = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;

    await Notification.updateMany(
      { user: userId, isRead: false },
      { isRead: true }
    );

    return res
      .status(200)
      .json({ message: "Tüm bildirimler okundu olarak işaretlendi." });
  } catch (err) {
    console.error("markAllAsRead error:", err);
    return res
      .status(500)
      .json({ message: "Bildirimler güncellenirken bir hata oluştu." });
  }
};

// ---- TEST amaçlı: Bildirim oluştur (ileri de otomatik oluşturulabilir) ----
// POST /api/notifications
exports.createNotification = async (req, res) => {
  try {
    const userId = req.user.id || req.user.userId;
    const { title, body, type } = req.body;

    if (!title) {
      return res.status(400).json({ message: "Başlık (title) zorunludur." });
    }

    const notification = await Notification.create({
      user: userId,
      title,
      body,
      type,
    });

    return res.status(201).json({
      message: "Bildirim oluşturuldu.",
      notification,
    });
  } catch (err) {
    console.error("createNotification error:", err);
    return res
      .status(500)
      .json({ message: "Bildirim oluşturulurken bir hata oluştu." });
  }
};
