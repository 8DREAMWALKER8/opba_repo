const Notification = require("../models/NotificationModel");

class NotificationRepositoryMongo {
  async findByUser(userId, { limit = 50 } = {}) {
    return Notification.find({ userId })
      .sort({ createdAt: -1 })
      .limit(limit);
  }

  async markRead(userId, notificationId) {
    const doc = await Notification.findOneAndUpdate(
      { _id: notificationId, userId },
      { $set: { isRead: true } },
      { new: true }
    );
    return doc;
  }

  async markAllRead(userId) {
    const res = await Notification.updateMany(
      { userId, isRead: false },
      { $set: { isRead: true } }
    );
    return { modifiedCount: res.modifiedCount ?? res.nModified ?? 0 };
  }
}

module.exports = NotificationRepositoryMongo;
