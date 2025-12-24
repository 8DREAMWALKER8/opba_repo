const express = require("express");
const router = express.Router();

// Controller'ı doğru path ile import et
const authController = require("../controllers/authController");

// Auth
router.post("/register", authController.register);
router.post("/login", authController.login);
router.post("/logout", authController.logout);

// Şifremi Unuttum akışı
router.post("/forgot-password", authController.forgotPassword);
router.post("/verify-reset-code", authController.verifyResetCode);
router.post("/reset-password", authController.resetPassword);

module.exports = router;
