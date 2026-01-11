/**
 * Bu dosya, istemciden gelen isteğe göre kullanılacak dili belirleyen ve
 * ilgili çeviri metnini döndüren yardımcı fonksiyonları içerir.
 */

const content = require("./content");

function normalizeLang(value) {
  if (!value) return null;
  const v = String(value).toLowerCase();
  if (v.startsWith("en")) return "en";
  if (v.startsWith("tr")) return "tr";
  return null;
}

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
