/**
 * Bu dosya uygulama genelinde kullanılan doğrulama (validation) yardımcılarını içerir.
 * Geçerli para birimi ve dil kontrolü
 * Şifre güvenliği için regex tanımı
 * Frontend'den gelen verileri standart hale getirmek
 */

const ALLOWED_CURRENCIES = ["TRY", "USD", "EUR", "GBP"];
const ALLOWED_LANGUAGES = ["tr", "en"];

// En az 8 karakter, 1 büyük, 1 küçük, 1 özel karakter
const PASSWORD_REGEX =
  /^(?=.*[a-z])(?=.*[A-Z])(?=.*[^A-Za-z0-9]).{8,}$/;

function normalizeCurrency(input) {
  if (!input) return input;
  const v = String(input).trim().toUpperCase();
  if (v === "TR") return "TRY";
  return v;
}

function normalizeLanguage(input) {
  if (!input) return input;
  return String(input).trim().toLowerCase();
}

module.exports = {
  ALLOWED_CURRENCIES,
  ALLOWED_LANGUAGES,
  PASSWORD_REGEX,
  normalizeCurrency,
  normalizeLanguage,
};
