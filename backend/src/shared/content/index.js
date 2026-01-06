// src/shared/content/index.js
const content = require("./content");

function normalizeLang(value) {
  if (!value) return null;
  const v = String(value).toLowerCase();
  if (v.startsWith("en")) return "en";
  if (v.startsWith("tr")) return "tr";
  return null;
}

/**
 * Dil seçimi önceliği:
 * 1) req.user.language (auth'lu istekler)
 * 2) x-lang / x-language header
 * 3) accept-language header
 * 4) req.body.language (register gibi auth'suz)
 * 5) default: tr
 */
function getLangFromReq(req) {
  const fromUser = normalizeLang(req?.user?.language);
  if (fromUser) return fromUser;

  const fromHeader =
    normalizeLang(req?.headers?.["x-lang"]) ||
    normalizeLang(req?.headers?.["x-language"]);
  if (fromHeader) return fromHeader;

  const accept = (req?.headers?.["accept-language"] || "").split(",")[0];
  const fromAccept = normalizeLang(accept);
  if (fromAccept) return fromAccept;

  const fromBody = normalizeLang(req?.body?.language);
  if (fromBody) return fromBody;

  return "tr";
}

/**
 * key: "errors.INVALID_CREDENTIALS" veya "enums.currency.TRY"
 * fallback: bulunamazsa dönecek metin
 */
function t(req, key, fallback) {
  const lang = req?.lang || getLangFromReq(req);
  const dict = content[lang] || content.tr;

  const parts = String(key).split(".");
  let cur = dict;
  for (const p of parts) {
    cur = cur?.[p];
  }

  return cur || fallback || key;
}

module.exports = { t, getLangFromReq };
