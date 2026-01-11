module.exports = ({ getMyNotifications, markNotificationAsRead, markAllAsRead }) => ({
  getMine: async (req, res) => {
    const userId = req.user.userId; // token dogrulama protect middleware bunu set ediyor
    const limit = Number(req.query.limit || 50);
    const items = await getMyNotifications.execute({ userId, limit });
    res.json({ ok: true, notifications: items });
  },

  markRead: async (req, res) => {
    const userId = req.user.userId;
    const { id } = req.params;
    const updated = await markNotificationAsRead.execute({ userId, notificationId: id });
    res.json({ ok: true, notification: updated });
  },

  markAllRead: async (req, res) => {
    const userId = req.user.userId;
    const out = await markAllAsRead.execute({ userId });
    res.json({ ok: true, ...out });
  },
});
