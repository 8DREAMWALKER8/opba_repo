//bildirim islemleri
class NotificationRepository {
  async findByUser() { throw new Error("NOT_IMPLEMENTED"); }
  async markRead() { throw new Error("NOT_IMPLEMENTED"); }
  async markAllRead() { throw new Error("NOT_IMPLEMENTED"); }
}
module.exports = NotificationRepository;
