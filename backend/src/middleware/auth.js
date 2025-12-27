/**
 * Bu middleware, kullanıcının giriş yapıp yapmadığını kontrol eder.
 * Authorization header içinden JWT token alır.
 * Token geçerliyse kullanıcıyı req.user içine ekler.
 * Geçersizse isteği engeller.
 */
const jwt = require("jsonwebtoken");

function requireAuth(req, res, next) {
  const auth = req.headers.authorization || "";
  const [type, token] = auth.split(" ");

  // Bearer yoksa veya token gelmediyse yetkisiz erişim
  if (type !== "Bearer" || !token) {
    return res.status(401).json({ ok: false, message: "Unauthorized" });
  }

  try {
    // Token doğrulanır (imza + süresi kontrol edilir)
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    // Token içindeki bilgiler request'e eklenir.
    // Böylece route'larda req.user.userId kullanılabilir.
    req.user = payload; 
    return next();
  } catch {
    return res.status(401).json({ ok: false, message: "Invalid or expired token" });
  }
}

module.exports = { requireAuth };
