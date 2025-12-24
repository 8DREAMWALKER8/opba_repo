const mongoose = require("mongoose");

const UserSchema = new mongoose.Schema(
  {
    username: { type: String, required: true, unique: true, trim: true },
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    phone: { type: String, required: true, trim: true },

    passwordHash: { type: String, required: true },

    resetCodeHash: { type: String, default: null },
    resetCodeExpiresAt: { type: Date, default: null },
    resetCodeAttempts: { type: Number, default: 0 },


    securityQuestionId: { type: String, required: true },
    securityAnswerHash: { type: String, required: true },

    language: { type: String, enum: ["tr", "en"], default: "tr" },
    currency: { type: String, enum: ["TRY", "USD", "EUR"], default: "TRY" },
    theme: { type: String, enum: ["light", "dark"], default: "light" },
  },
  { timestamps: true }
);

module.exports = mongoose.model("User", UserSchema);
