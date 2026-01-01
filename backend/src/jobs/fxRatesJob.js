const cron = require("node-cron");
const axios = require("axios");
const FxRate = require("../models/FxRate");

const TCMB_URL = process.env.TCMB_URL;

console.log("fxRatesJob yüklendi");
console.log("TCMB_URL:", TCMB_URL);

// "2025-12-24" gibi date string üretelim (TR saatine yakın olsun diye sadece gün bazlı)
function todayKey() {
  const d = new Date();
  // YYYY-MM-DD
  const yyyy = d.getFullYear();
  const mm = String(d.getMonth() + 1).padStart(2, "0");
  const dd = String(d.getDate()).padStart(2, "0");
  return `${yyyy}-${mm}-${dd}`;
}

// Basit XML içinden USD/EUR alış kurlarını çek (ForexSelling/ForexBuying yerine ihtiyaca göre değiştirebilirsin)
function parseTcmbRates(xml) {
  // USD
  const usdBlock = xml.match(/<Currency[^>]*CurrencyCode="USD"[\s\S]*?<\/Currency>/);
  const eurBlock = xml.match(/<Currency[^>]*CurrencyCode="EUR"[\s\S]*?<\/Currency>/);

  if (!usdBlock || !eurBlock) {
    throw new Error("TCMB XML içinde USD/EUR bulunamadı.");
  }

  // ForexSelling veya BanknoteSelling vs. Sen hangisini istiyorsan o alanı kullan
  // Burada ForexSelling'i alıyorum. Boş gelirse ForexBuying'e düşer.
  const getRate = (block) => {
    const selling = block[0].match(/<ForexSelling>(.*?)<\/ForexSelling>/)?.[1];
    const buying = block[0].match(/<ForexBuying>(.*?)<\/ForexBuying>/)?.[1];
    const val = (selling || buying || "").trim().replace(",", ".");
    const num = Number(val);
    if (!Number.isFinite(num) || num <= 0) throw new Error("Kur parse edilemedi.");
    return num;
  };

  return {
    USD: getRate(usdBlock),
    EUR: getRate(eurBlock),
    TRY: 1,
  };
}

async function upsertRates() {
  const key = todayKey();
  console.log(`FX fetch start (${key})...`);

  // TCMB çek
  const res = await axios.get(TCMB_URL, { timeout: 10000 });
  const xml = res.data;

  const rates = parseTcmbRates(xml);

  // DB upsert (aynı gün aynı currency tekrar yazılmasın)
  const docs = Object.entries(rates).map(([currency, rateToTRY]) => ({
    date: new Date(`${key}T00:00:00.000Z`),
    dayKey: key, // (modelinde yoksa kaldırabilirsin)
    currency,
    rateToTRY,
    source: "tcmb",
    fetchedAt: new Date(),
  }));

  // Model şeman buna uymuyorsa: date/currency/rateToTRY/source yeterli genelde.
  // Upsert: (date + currency) unique gibi düşün
  for (const d of docs) {
    await FxRate.updateOne(
      { date: d.date, currency: d.currency },
      { $set: d },
      { upsert: true }
    );
  }

  console.log(`FX rates updated: ${key}`, rates);
}

function startFxCron() {
  console.log("FX CRON STARTED");

  // Server açılınca 1 kere hemen çalıştır
  upsertRates().catch((e) => console.error("FX init failed:", e.message));

  // Her gün 09:05'te çalıştır (sunucu TR saatinde değilse timezone ayarlamak gerekir)
  cron.schedule("5 9 * * *", () => {
    console.log("FX CRON TRIGGERED");
    upsertRates().catch((e) => console.error("FX cron failed:", e.message));
  });

  // İstersen test için: 1 dakikada bir çalıştır (geçici)
  // cron.schedule("* * * * *", () => upsertRates().catch(console.error));
}

setTimeout(() => {
  upsertRates();
}, 3000);

module.exports = { startFxCron };

