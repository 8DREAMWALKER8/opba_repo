// ListAccounts.js
class ListAccounts {
  constructor({ repo, syncTcbmRates, fxRateRepo }) {
    this.repo = repo;
    this.syncTcbmRates = syncTcbmRates; // ✅ eklendi
    this.fxRateRepo = fxRateRepo;       // ✅ eklendi (kur dönüşümü yapacaksan)
  }

  // TCMB rate yapıları farklı olabildiği için esnek okuyoruz.
  // Ama ana varsayım: 1 FOREIGN = rate TRY
  _buildRateMap(rates) {
    const map = { TRY: 1 };

    console.log("Rates fetched for conversion:", rates);

    for (const r of rates || []) {
      // Mongoose doc gelebilir -> _doc fallback
      const obj = r?._doc ? r._doc : r;

      const code = (obj.currency || obj.code || obj.ccy || obj.symbol || "")
        .toString()
        .toUpperCase();

      if (!code) continue;

      // Yeni şema: rateToTRY
      const raw =
        obj.rateToTRY ??
        obj.rate ??
        obj.value ??
        obj.forexBuying ??
        obj.buying ??
        obj.tryRate ??
        obj.try ??
        null;

      const num = Number(raw);

      if (Number.isFinite(num) && num > 0) {
        map[code] = num;
      }
    }

    // TRY kaydı gelmese bile garanti
    map.TRY = 1;

    return map;
  }

  _convertAmount(amount, fromCurrency, toCurrency, rateMap) {
    const amt = Number(amount) || 0;
    const from = (fromCurrency || "TRY").toUpperCase();
    const to = (toCurrency || "TRY").toUpperCase();
    console.log(`Converting ${amt} from ${from} to ${to}`);
    if (from === to) return amt;
    console.log("Rate map:", rateMap);
    const fromRate = rateMap[from]; // 1 FROM = fromRate TRY
    const toRate = rateMap[to];     // 1 TO   = toRate   TRY

    // Rate bulunamazsa: convert edemiyoruz -> aynı bırak
    if (!fromRate || !toRate) return amt;

    // FROM -> TRY -> TO
    const inTry = amt * fromRate;
    const out = inTry / toRate;
    console.log(`Converted amount: ${out}`);
    return out;
  }

  async execute({ userId, selectedCurrency }) {
    // 1) Önce TCMB sync (best-effort)
    console.log("list accounts started");
        // 1) Önce TCMB sync (best-effort)
    const {date, rates} = await this.syncTcbmRates.execute();;
    

    // 2) Accounts çek
    let accounts = await this.repo.listActiveByUser(userId);

    // selectedCurrency yoksa direkt dön
    if (!selectedCurrency) return accounts;

    const target = selectedCurrency.toUpperCase();
    console.log("Target:" + target);
    // 3) FX rate'leri   oku (bugünün verisi)
    // fxRateRepo’da hangi metot varsa onu kullanmalısın.
    // Ben örnek olarak "getLatestByDate(date)" varsaydım.
    let rateMap = { TRY: 1 };

    if (this.fxRateRepo && this.syncTcbmRates) {
      try {
        const today = this.syncTcbmRates.dayStartUTC();

        // ÖRNEK: fxRateRepo.getLatest(today) -> [{ code:'USD', rate: 32.1 }, ...]
        const rates = await this.fxRateRepo.getLatest();
        rateMap = this._buildRateMap(rates);
      } catch (e) {
        // rate okuma hatasında convert yapmadan devam et
      }
    }

    // 4) Balance convert et
    accounts = accounts.map((account) => {
      const from = (account.currency || "TRY").toUpperCase();
      const newValue = this._convertAmount(account.balance, from, target, rateMap);

      return {
        ...account,
        balance: newValue,
        currency: target, // UI "seçilen currency" gösteriyorsa mantıklı
      };
    });

    return accounts;
  }
}

module.exports = ListAccounts;