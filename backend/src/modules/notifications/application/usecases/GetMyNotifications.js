class GetMyNotifications {
  constructor({ notificationRepo }) {
    this.notificationRepo = notificationRepo;
  }

  async execute({ userId, limit }) {
    const items = await this.notificationRepo.findByUser(userId, { limit });
    return items;
  }
}

module.exports = GetMyNotifications;
