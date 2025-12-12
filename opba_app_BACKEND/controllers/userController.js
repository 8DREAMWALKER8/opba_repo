const User = require("../models/User");

// --------------- PROFİLİ GETİR (ME) ---------------
exports.getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select(
      "-password -securityAnswer -resetPasswordCode -resetPasswordCodeExpire"
    );

    if (!user) {
      return res.status(404).json({ message: "Kullanıcı bulunamadı." });
    }

    return res.status(200).json({
      message: "Kullanıcı profili getirildi.",
      user,
    });
  } catch (err) {
    console.error("Get profile error:", err);
    return res.status(500).json({ message: "Sunucu hatası." });
  }
};

// --------------- PROFİL GÜNCELLE (ME) ---------------
exports.updateProfile = async (req, res) => {
  try {
    const { name, username, email, phone } = req.body;

    const updateData = {};
    if (name) updateData.name = name;
    if (username) updateData.username = username;
    if (email) updateData.email = email;
    if (phone) updateData.phone = phone;

    const user = await User.findByIdAndUpdate(req.user.id, updateData, {
      new: true,
      runValidators: true,
    }).select("-password -securityAnswer -resetPasswordCode -resetPasswordCodeExpire");

    if (!user) {
      return res.status(404).json({ message: "Kullanıcı bulunamadı." });
    }

    return res.status(200).json({
      message: "Profil başarıyla güncellendi.",
      user,
    });
  } catch (err) {
    console.error("Update profile error:", err);
    return res.status(500).json({ message: "Sunucu hatası." });
  }
};

// --------------- DİL TERCİHİ GETİR ---------------
exports.getLanguagePreference = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select("language");

    if (!user) {
      return res.status(404).json({ message: "Kullanıcı bulunamadı." });
    }

    return res.status(200).json({
      message: "Dil tercihi getirildi.",
      language: user.language,
    });
  } catch (err) {
    console.error("Get language error:", err);
    return res.status(500).json({ message: "Sunucu hatası." });
  }
};

// --------------- DİL TERCİHİ GÜNCELLE ---------------
exports.updateLanguagePreference = async (req, res) => {
  try {
    let { language } = req.body;

    if (!language) {
      return res.status(400).json({ message: "Dil bilgisi zorunludur." });
    }

    language = language.toLowerCase();
    const validLanguages = ["tr", "en"];

    if (!validLanguages.includes(language)) {
      return res.status(400).json({ message: "Geçersiz dil seçimi." });
    }

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { language },
      { new: true, runValidators: true }
    ).select("language");

    if (!user) {
      return res.status(404).json({ message: "Kullanıcı bulunamadı." });
    }

    return res.status(200).json({
      message: "Dil tercihi güncellendi.",
      language: user.language,
    });
  } catch (err) {
    console.error("Update language error:", err);
    return res.status(500).json({ message: "Sunucu hatası." });
  }
};

// --------------- PARA BİRİMİ TERCİHİ GETİR ---------------
exports.getCurrencyPreference = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select("currency");

    if (!user) {
      return res.status(404).json({ message: "Kullanıcı bulunamadı." });
    }

    return res.status(200).json({
      message: "Para birimi tercihi getirildi.",
      currency: user.currency,
    });
  } catch (err) {
    console.error("Get currency error:", err);
    return res.status(500).json({ message: "Sunucu hatası." });
  }
};

// --------------- PARA BİRİMİ TERCİHİ GÜNCELLE ---------------
exports.updateCurrencyPreference = async (req, res) => {
  try {
    let { currency } = req.body;

    if (!currency) {
      return res.status(400).json({ message: "Para birimi zorunludur." });
    }

    currency = currency.toUpperCase();
    const validCurrencies = ["TRY", "USD", "EUR"];

    if (!validCurrencies.includes(currency)) {
      return res.status(400).json({ message: "Geçersiz para birimi." });
    }

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { currency },
      { new: true, runValidators: true }
    ).select("currency");

    if (!user) {
      return res.status(404).json({ message: "Kullanıcı bulunamadı." });
    }

    return res.status(200).json({
      message: "Para birimi tercihi güncellendi.",
      currency: user.currency,
    });
  } catch (err) {
    console.error("Update currency error:", err);
    return res.status(500).json({ message: "Sunucu hatası." });
  }
};
