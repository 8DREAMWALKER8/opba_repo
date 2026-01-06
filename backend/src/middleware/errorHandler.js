const { ZodError } = require("zod");
const { t } = require("../shared/content");

function errorHandler(err, req, res, next) {
  // --------------------
  // Zod validation error
  // --------------------
  if (err instanceof ZodError) {
    return res.status(400).json({
      ok: false,
      message: t(req, "errors.VALIDATION_ERROR", "Validation error"),
      issues: err.issues?.map((i) => ({
        path: i.path.join("."),
        // issues içindeki CODE'u da çevir
        message: t(req, `errors.${i.message}`, i.message),
        // frontend için kodu ayrıca gönder
        code: i.message,
      })),
    });
  }

  // --------------------
  // Mongo duplicate key (E11000)
  // --------------------
  // Mongoose/MongoDB unique index çakışmaları burada yakalanır.
  // Örn: userId + iban unique ise aynı kullanıcı aynı iban'ı ekleyince code=11000 gelir.
  if (err && (err.code === 11000 || err.name === "MongoServerError")) {
    const keyPattern = err.keyPattern || {};
    const msg = String(err.message || "");

    const isUserIdIbanDuplicate =
      (("userId" in keyPattern) && ("iban" in keyPattern)) ||
      msg.includes("userId_1_iban_1");

    if (isUserIdIbanDuplicate) {
      return res.status(409).json({
        ok: false,
        message: t(
          req,
          "errors.ACCOUNT_DUPLICATE_IBAN",
          "This IBAN is already added."
        ),
      });
    }

    // Diğer unique çakışmalar için genel
    return res.status(409).json({
      ok: false,
      message: t(req, "errors.DUPLICATE_KEY", "Duplicate value."),
    });
  }

  // --------------------
  // Generic errors
  // --------------------
  const status = err.statusCode || 500;

  // Eğer err.message bir CODE ise content'ten çevir
  const message =
    typeof err.message === "string"
      ? t(req, `errors.${err.message}`, err.message)
      : t(req, "errors.INTERNAL_SERVER_ERROR", "Internal server error");

  return res.status(status).json({
    ok: false,
    message,
  });
}

module.exports = { errorHandler };
