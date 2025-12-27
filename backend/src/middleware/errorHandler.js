/**
 * Global hata yakalama middleware'i uygulamada oluşan tüm hataları tek yerden yönetir.
 */

function errorHandler(err, req, res, next) {
  console.error("Error:", err);

// Zod validation hatalarını yakalar
// Kullanıcı yanlış veri gönderirse 400 döner
  if (err && err.name === "ZodError") {
    return res.status(400).json({
      ok: false,
      message: "Validation error",
      errors: err.errors,
    });
  }

// MongoDB unique index hatası aynı IBAN'ın ikinci kez eklenmesini engeller.
  if (err && err.code === 11000) {
    return res.status(409).json({
      ok: false,
      message: "Bu IBAN zaten ekli.",
      details: err.keyValue,
    });
  }

  // Yukarıdakilere girmeyen tüm hatalar burada yakalanı 500 Internal Server Error döner.
  return res.status(err.statusCode || 500).json({
    ok: false,
    message: err.message || "Internal Server Error",
  });
}

module.exports = { errorHandler };
