class GetMyNotifications { //bildiirmleri döner
  constructor({ notificationRepo }) {
    this.notificationRepo = notificationRepo;
  }

  _normalizeLimit(limit) {
    const n = Number(limit);
    if (!Number.isFinite(n) || n <= 0) return 50;
    return Math.min(n, 200); // üst limit koruması
  }

  _normalizeIsRead(isRead) {
    // Controller query string gönderirse: "true"/"false"
    if (typeof isRead === "string") {
      const v = isRead.trim().toLowerCase();
      if (v === "true") return true;
      if (v === "false") return false;
      return undefined;
    }
    // Usecase boolean alırsa
    if (typeof isRead === "boolean") return isRead;

    return undefined;
  }

  async execute({ userId, limit, isRead }) {
    if (!userId) throw new Error("USER_ID_REQUIRED");

    const lim = this._normalizeLimit(limit);
    const read = this._normalizeIsRead(isRead);

    const items = await this.notificationRepo.findByUser(userId, {
      limit: lim,
      isRead: read,
    });

    return items;
  }
}

module.exports = GetMyNotifications;