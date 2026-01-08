// src/models/User.js
const mongoose = require("mongoose");

const LANGUAGES = ["tr", "en"];
const CURRENCIES = ["TRY", "USD", "EUR", "GBP"];
const THEMES = ["light", "dark"];

const UserSchema = new mongoose.Schema(
  {
    username: { type: String, required: true, unique: true, trim: true },

    email: { type: String, required: true, unique: true, lowercase: true, trim: true },

    phone: { type: String, required: true, trim: true },

    passwordHash: { type: String, required: true },

    // Password reset
    resetCodeHash: { type: String, default: null },
    resetCodeExpiresAt: { type: Date, default: null },
    resetCodeAttempts: { type: Number, default: 0 },

    // Security question
    securityQuestionId: { type: String, required: true },
    securityAnswerHash: { type: String, required: true },

    // Preferences
    language: { type: String, enum: LANGUAGES, default: "tr" },
    currency: { type: String, enum: CURRENCIES, default: "TRY" },
    theme: { type: String, enum: THEMES, default: "light" },
  },
  { timestamps: true }
);

module.exports = mongoose.model("User", UserSchema);
