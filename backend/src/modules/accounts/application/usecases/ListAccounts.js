/**
 * Bu sınıf, kullanıcıya ait aktif banka hesaplarını listelemek için kullanılır.
 * İsteğe bağlı olarak TCMB döviz kurlarını kullanarak
 * hesap bakiyelerini seçilen para birimine dönüştürür.
 */

class ListAccounts {
  constructor({ repo, syncTcbmRates, fxRateRepo }) {
    this.repo = repo;
    this.syncTcbmRates = syncTcbmRates; 
    this.fxRateRepo = fxRateRepo;      
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
        obj.tryRate ??
        obj.try ??
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

    if (!fromRate || !toRate) return amt;

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

    if (!selectedCurrency) return accounts;

    const target = selectedCurrency.toUpperCase();
    console.log("Target:" + target);
    // 3) FX rate'leri oku 
    let rateMap = { TRY: 1 };

    if (this.fxRateRepo && this.syncTcbmRates) {
      try {
        const today = this.syncTcbmRates.dayStartUTC();

        const rates = await this.fxRateRepo.getLatest();
        rateMap = this._buildRateMap(rates);
      } catch (e) {
        
      }
    }

    // 4) Balance convert et
    accounts = accounts.map((account) => {
      const from = (account.currency || "TRY").toUpperCase();
      const newValue = this._convertAmount(account.balance, from, target, rateMap);

      return {
        ...account,
        balance: newValue,
        currency: target, 
      };
    });

    return accounts;
  }
}

module.exports = ListAccounts;