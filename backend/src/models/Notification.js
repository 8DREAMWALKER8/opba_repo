/**
 * Notification modeli
 * Kullanıcıya gösterilecek bildirimleri tutar.
 */
const mongoose = require("mongoose");

const notificationSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },

    title: { type: String, required: true, trim: true },
    body: { type: String, trim: true, default: "" },

    type: {
      type: String,
      enum: [
        "monthly_summary",
        "limit_exceeded",
        "weekly_spending_alert",
        "recurring_payment",
        "goal_reached",
        "general",
      ],
      default: "general",
      index: true,
    },

    isRead: { type: Boolean, default: false, index: true },

    // aynı ay/kategori/hafta için aynı bildirimi tekrar tekrar üretmeyi engeller (opsiyonel ama çok iyi)
    dedupeKey: { type: String, trim: true, index: true },
  },
  { timestamps: true }
);

// dedupeKey varsa aynı kullanıcı için tekrar üretilmesin
notificationSchema.index(
  { userId: 1, dedupeKey: 1 },
  { unique: true, partialFilterExpression: { dedupeKey: { $type: "string" } } }
);

module.exports = mongoose.model("Notification", notificationSchema);
