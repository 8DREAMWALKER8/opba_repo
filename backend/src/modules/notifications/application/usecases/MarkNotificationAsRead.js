class MarkNotificationAsRead {//bildirim varsa belirli bildirimi okundu yap yoksa hata
  constructor({ notificationRepo }) {
    this.notificationRepo = notificationRepo;
  }

  async execute({ userId, notificationId }) {
    const updated = await this.notificationRepo.markRead(userId, notificationId);
    if (!updated) {
      const err = new Error("NOTIFICATION_NOT_FOUND");
      err.status = 404;
      throw err;
    }
    return updated;
  }
}

module.exports = MarkNotificationAsRead;
