// Bu repository, döviz kuru verilerinin MongoDB üzerinde upsert edilmesini ve en güncel kur kayıtlarının sıralı şekilde getirilmesini sağlar.

const FxRate = require("../models/FxRateModel");

class FxRateRepositoryMongo {
  async upsertMany(rates, date) {
    const docs = Object.entries(rates).map(([currency, rateToTRY]) => ({
      date,
      currency,
      rateToTRY,
      source: "tcmb",
    }));

    for (const d of docs) {
      await FxRate.updateOne(
        { date: d.date, currency: d.currency },
        { $set: d },
        { upsert: true }
      );
    }
  }

  async getLatest(limit = 50) {
    return FxRate.find().sort({ date: -1 }).limit(limit);
  }
}

module.exports = FxRateRepositoryMongo;
