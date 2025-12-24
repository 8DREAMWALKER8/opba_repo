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

    // Kartın içinde gözükecek ana metin
    title: {
      type: String,
      required: true,
      trim: true,
    },

    // Detay metin (opsiyonel)
    body: {
      type: String,
      trim: true,
      default: "",
    },

    // Bildirim tipi
    type: {
      type: String,
      enum: ["monthly_summary", "limit_exceeded", "goal_reached", "general"],
      default: "general",
      index: true,
    },

    // Okundu mu?
    isRead: {
      type: Boolean,
      default: false,
      index: true,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Notification", notificationSchema);
