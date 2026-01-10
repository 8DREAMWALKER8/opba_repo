// GetMyTransactions.js
class GetMyTransactions {
  constructor({ transactionRepo, fxRateRepo, syncTcbmRates }) {
    this.transactionRepo = transactionRepo;
    this.fxRateRepo = fxRateRepo;
    this.syncTcbmRates = syncTcbmRates;
  }

  _buildRateMap(rates) {
    // DB şeman: { currency, rateToTRY }
    const map = { TRY: 1 };
    // console.log("Rates fetched for conversion:", rates); 
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
        map[code] = num; // 1 CODE = num TRY
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

    const fromRate = rateMap[from]; // 1 FROM = fromRate TRY
    const toRate = rateMap[to];     // 1 TO   = toRate   TRY
    console.log(`Converting ${amt} from ${from} to ${to} using rates ${fromRate} and ${toRate}`);
    if (!fromRate || !toRate) return amt; // rate yoksa convert etme

    // FROM -> TRY -> TO
    const inTry = amt * fromRate;
    return inTry / toRate;
  }

  async execute({ userId, limit, skip, type, category, accountId, currency }) {
    // 1) Tx listesi
    const items = await this.transactionRepo.findByUserId(userId, {
      limit,
      skip,
      type,
      category,
      accountId,
    });
    console.log('currency in GetMyTransactions usecase:', currency);
    // currency yoksa aynen dön
    if (!currency) return items;

    const target = String(currency).toUpperCase();

    // 2) TCMB sync (best-effort)
    if (this.syncTcbmRates) {
      try {
        await this.syncTcbmRates.execute();
      } catch (_) {
        // TCMB hata verirse tx listesi yine dönsün
      }
    }

    // 3) Rate map
    let rateMap = { TRY: 1 };

    if (this.fxRateRepo) {
      try {
        const today = this.syncTcbmRates.dayStartUTC();

        // ÖRNEK: fxRateRepo.getLatest(today) -> [{ code:'USD', rate: 32.1 }, ...]
        const rates = await this.fxRateRepo.getLatest();
        rateMap = this._buildRateMap(rates);
        // console.log("Built rate map:", rateMap);
      } catch (_) {
        // rate okunamazsa convert etmeden devam
      }
    }

    // 4) Convert
    return (items || []).map((tx) => {
      const obj = tx?._doc ? tx._doc : tx;

      const from = (obj.currency || "TRY").toUpperCase();
      // console.log(`Converting transaction ${obj._id} amount from ${from} to ${target}`);
      const converted = this._convertAmount(obj.amount, from, target, rateMap);
      // console.log(`Converted amount: ${converted}`);
      return {
        ...obj,

        // istersen orijinalleri de koru:
        originalAmount: obj.amount,
        originalCurrency: obj.currency || "TRY",

        amount: converted,
        currency: target,
      };
    });
  }
}

module.exports = GetMyTransactions;