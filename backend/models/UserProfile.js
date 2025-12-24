const mongoose = require("mongoose");

const UserProfileSchema = new mongoose.Schema(
  {
    // CSV alanları
    userId: { type: Number, unique: true, index: true }, // user_id
    username: { type: String, index: true },
    email: { type: String },

    firstName: String,
    lastName: String,
    fullName: String,

    customerAge: Number,
    income: Number,
    employmentStatus: String,
    housingStatus: String,
    creditRiskScore: Number,
    bankMonthsCount: Number,
    hasOtherCards: Number,
    emailIsFree: Number,
  },
  { timestamps: true }
);

module.exports = mongoose.model("UserProfile", UserProfileSchema);
