const Notification = require("../models/NotificationModel");

class NotificationRepositoryMongo {
  // CreateTransaction burayı çağıracak
  async create(data) {
    const doc = await Notification.create({
      userId: data.userId,
      type: data.type,
      title: data.title,
      message: data.message,
      meta: data.meta || {},
      isRead: false,
    });

    return doc.toObject ? doc.toObject() : doc;
  }

  async findByUser(userId, { limit = 50, isRead } = {}) {
    const filter = { userId };

    // isRead parametresi verilmişse filtrele
    if (typeof isRead === "boolean") {
      filter.isRead = isRead;
    }

    return Notification.find(filter)
      .sort({ createdAt: -1 })
      .limit(Number(limit));
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
