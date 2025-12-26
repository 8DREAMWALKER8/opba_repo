/**
 * Notification modeli
 * Kullanıcıya gösterilecek bildirimleri tutar.
 */
const mongoose = require("mongoose");

const notificationSchema = new mongoose.Schema(
  {
    // Bu bildirimin hangi kullanıcıya ait olduğu
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },

    // Bildirim kartında görünen metinler
    title: {
      type: String,
      required: true,
      trim: true,
    },

    // Detay metin
    body: {
      type: String,
      trim: true,
      default: "",
    },

    // Bildirimin türü (bütçe aşıldı, özet, genel vs.)
    type: {
      type: String,
      enum: ["monthly_summary", "limit_exceeded", "goal_reached", "general"],
      default: "general",
      index: true,
    },

    // Okundu / okunmadı bilgisi
    isRead: {
      type: Boolean,
      default: false,
      index: true,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Notification", notificationSchema);
