// Kullanıcının işlemlerini listeler ve istenirse döviz kuru bilgilerini kullanarak işlem tutarlarını seçilen para birimine çevirip geri döndürür.

class GetMyTransactions {
  constructor({ transactionRepo, fxRateRepo, syncTcbmRates }) {
    this.transactionRepo = transactionRepo;
    this.fxRateRepo = fxRateRepo;
    this.syncTcbmRates = syncTcbmRates;
  }

  _buildRateMap(rates) {
    const map = { TRY: 1 };
    for (const r of rates || []) {
      const obj = r?._doc ? r._doc : r;

      const code = (obj.currency || obj.code || obj.ccy || obj.symbol || "")
        .toString()
        .toUpperCase();
      if (!code) continue;

      const raw =
        obj.rateToTRY ??
        obj.rate ??
        obj.value ??
        obj.forexBuying ??
        obj.buying ??
        null;

      const num = Number(raw);
      if (Number.isFinite(num) && num > 0) {
        map[code] = num;
      }
    }

    map.TRY = 1;
    return map;
  }

  _convertAmount(amount, fromCurrency, toCurrency, rateMap) {
    const amt = Number(amount) || 0;
    const from = (fromCurrency || "TRY").toUpperCase();
    const to = (toCurrency || "TRY").toUpperCase();

    if (from === to) return amt;

    const fromRate = rateMap[from];
    const toRate = rateMap[to];
    console.log(`Converting ${amt} from ${from} to ${to} using rates ${fromRate} and ${toRate}`);
    if (!fromRate || !toRate) return amt;

    const inTry = amt * fromRate;
    return inTry / toRate;
  }

  async execute({ userId, limit, skip, type, category, accountId, currency }) {
    const items = await this.transactionRepo.findByUserId(userId, {
      limit,
      skip,
      type,
      category,
      accountId,
    });
    if (!currency) return items;

    const target = String(currency).toUpperCase();

    if (this.syncTcbmRates) {
      try {
        await this.syncTcbmRates.execute();
      } catch (_) {
      }
    }

    let rateMap = { TRY: 1 };

    if (this.fxRateRepo) {
      try {
        const today = this.syncTcbmRates.dayStartUTC();

        const rates = await this.fxRateRepo.getLatest();
        rateMap = this._buildRateMap(rates);
      } catch (_) {
      }
    }

    return (items || []).map((tx) => {
      const obj = tx?._doc ? tx._doc : tx;

      const from = (obj.currency || "TRY").toUpperCase();
      const converted = this._convertAmount(obj.amount, from, target, rateMap);
      return {
        ...obj,

        originalAmount: obj.amount,
        originalCurrency: obj.currency || "TRY",

        amount: converted,
        currency: target,
      };
    });
  }
}

module.exports = GetMyTransactions;