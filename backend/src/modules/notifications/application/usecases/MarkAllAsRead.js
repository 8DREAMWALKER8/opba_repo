class MarkAllAsRead { //id'ye gore tum bildirimleri okur
  constructor({ notificationRepo }) {
    this.notificationRepo = notificationRepo;
  }

  async execute({ userId }) {
    return await this.notificationRepo.markAllRead(userId);
  }
}

module.exports = MarkAllAsRead;
