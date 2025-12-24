function errorHandler(err, req, res, next) {
  console.error("Error:", err);

  // Zod validation hataları
  if (err && err.name === "ZodError") {
    return res.status(400).json({
      ok: false,
      message: "Validation error",
      errors: err.errors,
    });
  }

  // MongoDB duplicate key (unique index) hatası
  // Örn: aynı kullanıcı aynı IBAN'ı eklemeye çalışırsa
  if (err && err.code === 11000) {
    return res.status(409).json({
      ok: false,
      message: "Bu IBAN zaten ekli.",
      details: err.keyValue,
    });
  }

  // Diğer tüm hatalar (default)
  return res.status(err.statusCode || 500).json({
    ok: false,
    message: err.message || "Internal Server Error",
  });
}

module.exports = { errorHandler };
