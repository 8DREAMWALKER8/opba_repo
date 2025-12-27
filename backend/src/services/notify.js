const Notification = require("../models/Notification");

async function createNotification({ userId, type, title, body = "", dedupeKey }) {
  try {
    const doc = await Notification.create({ userId, type, title, body, dedupeKey });
    return doc;
  } catch (err) {
    // unique dedupeKey patlarsa sessiz geç (zaten var demek)
    if (err?.code === 11000) return null;
    throw err;
  }
}

module.exports = { createNotification };
