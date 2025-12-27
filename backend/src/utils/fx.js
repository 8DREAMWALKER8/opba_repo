
/**
 * Hesap bakiyelerini TRY cinsine çevirir.
 * Toplam bakiye ve grafiklerde ortak para birimi kullanılır.
 * Eğer para birimi zaten TRY ise dönüşüm yapılmaz (1 döner).
 * Kur bulunamazsa null döner
 */
const FxRate = require("../models/FxRate");

async function getRateToTRY(currency, date = new Date()) {
// Para birimini normalize ediyoruz (küçük/büyük harf farkı olmaması için)
  const c = String(currency || "TRY").toUpperCase();
  if (c === "TRY") return 1;

   // Döviz kurları günlük tutulduğu için seçilen günün UTC başlangıç ve bitiş saatleri hesaplanır.
   
  const start = new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate(), 0, 0, 0));
  const end = new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate() + 1, 0, 0, 0));


  // FxRate koleksiyonunda; istenen para birimi, istenen gün aralığı için kur aranır.
  const row = await FxRate.findOne({
    currency: c,
    date: { $gte: start, $lt: end },
  }).lean();

  return row?.rateToTRY ?? null;
}

module.exports = { getRateToTRY };
