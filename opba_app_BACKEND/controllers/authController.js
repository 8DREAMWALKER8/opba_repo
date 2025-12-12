const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const User = require("../models/User");

// --------------- KAYIT OL ---------------
exports.register = async (req, res) => {
  try {
    const {
      name,
      username,
      email,
      phone,
      password,
      securityQuestion,
      securityAnswer,
    } = req.body;

    if (
      !name ||
      !username ||
      !email ||
      !phone ||
      !password ||
      !securityQuestion ||
      !securityAnswer
    ) {
      return res.status(400).json({ message: "Tüm alanlar zorunludur." });
    }

    // Kullanıcı var mı?
    const existingUser = await User.findOne({
      $or: [{ email }, { username }],
    });

    if (existingUser) {
      return res
        .status(400)
        .json({ message: "Bu e-posta veya kullanıcı adı zaten kayıtlı." });
    }

    // Şifre ve güvenlik cevabını hashle
    const hashedPassword = await bcrypt.hash(password, 10);
    const hashedSecurityAnswer = await bcrypt.hash(securityAnswer, 10);

    const newUser = await User.create({
      name,
      username,
      email,
      phone,
      password: hashedPassword,
      securityQuestion,
      securityAnswer: hashedSecurityAnswer,
      // language alanı modelde default "tr" zaten
    });

    return res.status(201).json({
      message: "Kullanıcı kaydı başarılı.",
      user: {
        id: newUser._id,
        name: newUser.name,
        username: newUser.username,
        email: newUser.email,
      },
    });
  } catch (err) {
    console.error("Register error:", err);
    return res.status(500).json({ message: "Sunucu hatası." });
  }
};

// --------------- GİRİŞ (2 ADIMLI) ---------------
exports.login = async (req, res) => {
  console.log("LOGIN BODY:", req.body); // debug için

  try {
    // Hem eski ismi (usernameOrEmail) hem de yeni ismi (identifier) destekleyelim
    const {
      usernameOrEmail,
      identifier,
      password,
      userId,
      securityAnswer,
      step,
    } = req.body;

    // hangi alan doluysa onu kullan
    const loginIdentifier = identifier || usernameOrEmail;
    const currentStep = step || 1;

    console.log("STEP VALUE:", currentStep);
    console.log("LOGIN IDENTIFIER:", loginIdentifier);

    // ---- STEP 1: Şifre kontrolü, güvenlik sorusunu döndür ----
    if (currentStep === 1 || currentStep === "1") {
      if (!loginIdentifier || !password) {
        return res
          .status(400)
          .json({ message: "Kullanıcı adı/e-posta ve şifre zorunlu." });
      }

      const user = await User.findOne({
        $or: [{ email: loginIdentifier }, { username: loginIdentifier }],
      });

      if (!user) {
        return res
          .status(401)
          .json({ message: "Kullanıcı adı/e-posta veya şifre hatalı." });
      }

      const isPasswordMatch = await bcrypt.compare(password, user.password);
      if (!isPasswordMatch) {
        return res
          .status(401)
          .json({ message: "Kullanıcı adı/e-posta veya şifre hatalı." });
      }

      // Şifre doğruysa güvenlik sorusunu dön
      return res.status(200).json({
        message: "Giriş adım 1 başarılı. Güvenlik sorusunu cevaplayınız.",
        userId: user._id,
        securityQuestion: user.securityQuestion,
      });
    }

    // ---- STEP 2: Güvenlik cevabını kontrol et, token üret ----
    if (currentStep === 2 || currentStep === "2") {
      if (!userId || !securityAnswer) {
        return res.status(400).json({
          message: "Kullanıcı ve güvenlik cevabı bilgileri zorunludur.",
        });
      }

      const user = await User.findById(userId);
      if (!user) {
        return res.status(404).json({ message: "Kullanıcı bulunamadı." });
      }

      const isAnswerMatch = await bcrypt.compare(
        securityAnswer,
        user.securityAnswer
      );

      if (!isAnswerMatch) {
        return res
          .status(401)
          .json({ message: "Güvenlik sorusunun cevabı hatalı." });
      }

      const JWT_SECRET = process.env.JWT_SECRET || "dev-secret-key";

      const token = jwt.sign(
        { id: user._id },
        JWT_SECRET,
        {
          expiresIn: "1h",
        }
      );

      return res.status(200).json({
        message: "Giriş başarılı.",
        token,
        user: {
          id: user._id,
          name: user.name,
          username: user.username,
          email: user.email,
        },
      });
    }

    // Geçersiz step
    return res.status(400).json({ message: "Geçersiz step değeri." });
  } catch (err) {
    console.error("Login error:", err);
    return res.status(500).json({ message: "Sunucu hatası." });
  }
};

// --------------- LOGOUT ---------------
exports.logout = async (req, res) => {
  // Frontend token'ı sildiği için burada sadece bilgilendirme dönebiliriz
  return res.status(200).json({ message: "Çıkış başarılı." });
};

// --------------- ŞİFREMİ UNUTTUM (kod üret) ---------------
exports.forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ message: "E-posta zorunludur." });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res
        .status(404)
        .json({ message: "Bu e-posta ile kayıtlı bir kullanıcı yok." });
    }

    // 6 haneli kod
    const resetCode = Math.floor(100000 + Math.random() * 900000).toString();
    const hashedCode = await bcrypt.hash(resetCode, 10);

    user.resetPasswordCode = hashedCode;
    user.resetPasswordCodeExpire = Date.now() + 15 * 60 * 1000; // 15 dk
    await user.save();

    // Gerçekte mail gönderilir, biz şimdilik kodu response'ta dönebiliriz
    return res.status(200).json({
      message: "Şifre sıfırlama kodu oluşturuldu.",
      resetCode, // geliştirme için
    });
  } catch (err) {
    console.error("Forgot password error:", err);
    return res.status(500).json({ message: "Sunucu hatası." });
  }
};

// --------------- KOD DOĞRULAMA ---------------
exports.verifyResetCode = async (req, res) => {
  try {
    const { email, resetCode } = req.body;

    if (!email || !resetCode) {
      return res
        .status(400)
        .json({ message: "E-posta ve doğrulama kodu zorunludur." });
    }

    const user = await User.findOne({ email });
    if (
      !user ||
      !user.resetPasswordCode ||
      !user.resetPasswordCodeExpire ||
      user.resetPasswordCodeExpire < Date.now()
    ) {
      return res
        .status(400)
        .json({ message: "Kod geçersiz veya süresi dolmuş." });
    }

    const isMatch = await bcrypt.compare(resetCode, user.resetPasswordCode);
    if (!isMatch) {
      return res.status(400).json({ message: "Kod hatalı." });
    }

    return res.status(200).json({ message: "Kod doğrulandı." });
  } catch (err) {
    console.error("Verify reset code error:", err);
    return res.status(500).json({ message: "Sunucu hatası." });
  }
};

// --------------- ŞİFRE SIFIRLAMA ---------------
exports.resetPassword = async (req, res) => {
  try {
    const { email, newPassword } = req.body;

    if (!email || !newPassword) {
      return res
        .status(400)
        .json({ message: "E-posta ve yeni şifre zorunludur." });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res
        .status(404)
        .json({ message: "Bu e-posta ile kayıtlı kullanıcı bulunamadı." });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);

    user.password = hashedPassword;
    user.resetPasswordCode = undefined;
    user.resetPasswordCodeExpire = undefined;
    await user.save();

    return res.status(200).json({ message: "Şifre başarıyla güncellendi." });
  } catch (err) {
    console.error("Reset password error:", err);
    return res.status(500).json({ message: "Sunucu hatası." });
  }
};
