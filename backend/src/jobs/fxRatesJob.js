const cron = require("node-cron");
const axios = require("axios");
const FxRate = require("../models/FxRate");

const TCMB_URL = process.env.TCMB_URL;

console.log("fxRatesJob yüklendi");
console.log("TCMB_URL:", TCMB_URL);

// "2025-12-24" gibi date string üretiyoruz
function todayKey() {
  const d = new Date();
  // YYYY-MM-DD
  const yyyy = d.getFullYear();
  const mm = String(d.getMonth() + 1).padStart(2, "0");
  const dd = String(d.getDate()).padStart(2, "0");
  return `${yyyy}-${mm}-${dd}`;
}

// Basit XML içinden USD/EUR alış kurlarını çekiyoruz
function parseTcmbRates(xml) {
  // USD
  const usdBlock = xml.match(/<Currency[^>]*CurrencyCode="USD"[\s\S]*?<\/Currency>/);
  const eurBlock = xml.match(/<Currency[^>]*CurrencyCode="EUR"[\s\S]*?<\/Currency>/);
  const gbpBlock = xml.match(/<Currency[^>]*CurrencyCode="GBP"[\s\S]*?<\/Currency>/);

  if (!usdBlock || !eurBlock || !gbpBlock) {
    throw new Error("TCMB XML içinde USD/EUR/GBP bulunamadı.");
  }

  // ForexSelling veya BanknoteSelling vs.
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
    GBP: getRate(gbpBlock),
    TRY: 1,
  };
}

async function upsertRates() {
  const key = todayKey();
  console.log(`FX fetch start (${key})...`);

  // TCMB çekme
  const res = await axios.get(TCMB_URL, { timeout: 10000 });
  const xml = res.data;

  const rates = parseTcmbRates(xml);

  // DB upsert 
  const docs = Object.entries(rates).map(([currency, rateToTRY]) => ({
    date: new Date(`${key}T00:00:00.000Z`),
    dayKey: key, 
    currency,
    rateToTRY,
    source: "tcmb",
    fetchedAt: new Date(),
  }));
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
  console.log("FX CRON BAŞLADI.");

  upsertRates().catch((e) => console.error("FX init çöktü:", e.message));

  cron.schedule("5 9 * * *", () => {
    console.log("FX CRON TETİKLENDİ.");
    upsertRates().catch((e) => console.error("FX cron çöktü:", e.message));
  });

}

setTimeout(() => {
  upsertRates();
}, 3000);

module.exports = { startFxCron };

