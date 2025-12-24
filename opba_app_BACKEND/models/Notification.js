// models/Notification.js
const mongoose = require("mongoose");

const notificationSchema = new mongoose.Schema(
  {
    // Bu bildirimin hangi kullanıcıya ait olduğu
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    // Kartın içinde gözükecek ana metin
    title: {
      type: String,
      required: true,
      trim: true,
    },

    // İstersen ileride detaylı açıklama kullanmak için
    body: {
      type: String,
      trim: true,
    },

    // Bildirim tipi (şimdilik örnek, zorunlu değil)
    type: {
      type: String,
      enum: ["monthly_summary", "limit_exceeded", "goal_reached", "general"],
      default: "general",
    },

    // Kullanıcı bu bildirimi okudu mu?
    isRead: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true, // createdAt ve updatedAt alanlarını otomatik ekler
  }
);

module.exports = mongoose.model("Notification", notificationSchema);
