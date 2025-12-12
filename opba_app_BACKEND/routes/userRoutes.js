const express = require("express");
const router = express.Router();

const userController = require("../controllers/userController");
const { protect } = require("../middleware/authMiddleware");

// Giriş yapmış kullanıcının profilini getir
router.get("/me", protect, userController.getProfile);

// Giriş yapmış kullanıcının profilini güncelle
router.put("/me", protect, userController.updateProfile);

// Dil tercihleri
router.get("/me/language", protect, userController.getLanguagePreference);
router.put("/me/language", protect, userController.updateLanguagePreference);

// Para birimi tercihleri
router.get("/me/currency", protect, userController.getCurrencyPreference);
router.put("/me/currency", protect, userController.updateCurrencyPreference);

module.exports = router;
