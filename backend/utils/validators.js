// utils/validators.js

const ALLOWED_CURRENCIES = ["TRY", "USD", "EUR"];
const ALLOWED_LANGUAGES = ["tr", "en"];

// En az 8 karakter, 1 büyük, 1 küçük, 1 özel karakter
const PASSWORD_REGEX =
  /^(?=.*[a-z])(?=.*[A-Z])(?=.*[^A-Za-z0-9]).{8,}$/;

function normalizeCurrency(input) {
  if (!input) return input;
  const v = String(input).trim().toUpperCase();
  // Bazı yerlerde TR gönderiliyor; TRY'ye çekelim
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
