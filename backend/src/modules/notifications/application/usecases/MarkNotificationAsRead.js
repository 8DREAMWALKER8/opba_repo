class MarkNotificationAsRead {
  constructor({ notificationRepo }) {
    this.notificationRepo = notificationRepo;
  }

  async execute({ userId, notificationId }) {
    const updated = await this.notificationRepo.markRead(userId, notificationId);
    if (!updated) {
      const err = new Error("Notification not found");
      err.status = 404;
      throw err;
    }
    return updated;
  }
}

module.exports = MarkNotificationAsRead;
