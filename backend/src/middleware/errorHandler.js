// Uygulama genelinde hataları yakalayıp standart JSON response dönen middleware

const { ZodError } = require("zod");
const { t } = require("../shared/content");

function errorHandler(err, req, res, next) {

  if (err instanceof ZodError) {
    return res.status(400).json({
      ok: false,
      message: t(req, "errors.VALIDATION_ERROR", "Validation error"),
      issues: err.issues?.map((i) => ({
        path: i.path.join("."),
        message: t(req, `errors.${i.message}`, i.message),
        code: i.message,
      })),
    });
  }


  if (err && (err.code === 11000 || err.name === "MongoServerError")) {
    const keyPattern = err.keyPattern || {};
    const msg = String(err.message || "");
  console.log("DUPLICATE keyPattern:", err.keyPattern);
  console.log("DUPLICATE keyValue:", err.keyValue);   
  console.log("DUPLICATE message:", err.message);

    const isUserIdCardNumberDuplicate =
      (("userId" in keyPattern) && ("cardNumber" in keyPattern)) ||
      msg.includes("userId_1_cardNumber_1");

    if (isUserIdCardNumberDuplicate) {
      return res.status(409).json({
        ok: false,
        message: t(
          req,
          "errors.ACCOUNT_DUPLICATE_CARD_NUMBER"
        ),
      });
    }

    return res.status(409).json({
      ok: false,
      message: t(req, "errors.DUPLICATE_KEY"),
    });
  }

  const status = err.statusCode || 500;

  const message =
    typeof err.message === "string"
      ? t(req, `errors.${err.message}`, err.message)
      : t(req, "errors.INTERNAL_SERVER_ERROR");

  return res.status(status).json({
    ok: false,
    message,
  });
}

module.exports = { errorHandler };
