class GetBudgets {
  constructor({ budgetRepo, txRepo, fxRepo }) {
    this.budgetRepo = budgetRepo;
    this.txRepo = txRepo;
    this.fxRateRepo = fxRepo;
  }

  _resolvePeriod(budget) {
    if (budget.year && budget.month) {
      const y = Number(budget.year);
      const m = Number(budget.month);

      if (!Number.isFinite(y) || !Number.isFinite(m) || m < 1 || m > 12) {
        throw new Error("INVALID_BUDGET_PERIOD");
      }

      const from = new Date(y, m - 1, 1);
      const to = new Date(y, m, 1);
      return { from, to };
    }

    if (typeof budget.month === "string" && budget.month.includes("-")) {
      const [yy, mm] = budget.month.split("-");
      const y = Number(yy);
      const m = Number(mm);

      if (!Number.isFinite(y) || !Number.isFinite(m) || m < 1 || m > 12) {
        throw new Error("INVALID_BUDGET_PERIOD");
      }

      const from = new Date(y, m - 1, 1);
      const to = new Date(y, m, 1);
      return { from, to };
    }

    throw new Error("BUDGET_PERIOD_REQUIRED");
  }

  _normalizeCurrency(cur) {
    const c = String(cur || "").trim().toUpperCase();
    return c || null;
  }

  // FX dönüşümü: sourceCurrency -> targetCurrency (rateToTRY mantığı ile)
  // fxRepo'nun elindeki model: { currency, rateToTRY, date }
  // Varsayım: rateToTRY = 1 unit currency kaç TRY eder? (TCMB gibi)
  async _convertAmountFx({ amount, sourceCurrency, targetCurrency }) {
    const src = this._normalizeCurrency(sourceCurrency) || "TRY";
    const tgt = this._normalizeCurrency(targetCurrency) || "TRY";

    const amt = Number(amount);
    if (!Number.isFinite(amt)) return 0;

    if (src === tgt) return amt;

    // TRY -> X veya X -> TRY veya X -> Y
    // Bunun için: srcToTRY ve tgtToTRY rate'leri gerekir.
    // fxRepo.getLatest() kullanıyoruz (sende var).
    const latestRates = await this.fxRateRepo.getLatest(200);
    const map = new Map();
    for (const r of latestRates) {
      map.set(String(r.currency).toUpperCase(), Number(r.rateToTRY));
    }

    const srcToTRY = src === "TRY" ? 1 : map.get(src);
    const tgtToTRY = tgt === "TRY" ? 1 : map.get(tgt);

    if (!srcToTRY || !tgtToTRY) {
      // rate yoksa güvenli fallback: amount'u aynen döndür (veya error fırlat)
      return amt;
    }

    // amt (src) -> TRY -> tgt
    const tryAmount = amt * srcToTRY;
    const converted = tryAmount / tgtToTRY;
    return converted;
  }

  async execute({ userId, currency }) {
    if (!userId) throw new Error("USER_ID_REQUIRED");

    const budgets = await this.budgetRepo.findByUser(userId);
    if (!budgets || budgets.length === 0) return [];

    const requestedCurrency = this._normalizeCurrency(currency);

    const withSpent = await Promise.all(
      budgets.map(async (b) => {
        const { from, to } = this._resolvePeriod(b);

        // hedef currency: frontend > budget.currency > TRY
        const budgetCurrency = this._normalizeCurrency(b.currency);
        const targetCurrency = requestedCurrency || budgetCurrency || "TRY";

        const category = b.category;

        // 1) spent: TX repo içinde FX ile targetCurrency’e göre hesaplanıyor
        const spent = await this.txRepo.sumExpensesByUserAndCategoryBetweenFx({
          userId,
          category,
          from,
          to,
          targetCurrency,
          fxRateRepo: this.fxRateRepo,
        });

        // 2) limitAmount: budget'ın kendi currency'sinden targetCurrency'e çevir
        // budget.currency yoksa TRY varsayıyoruz
        console.log('limit amount : ' + b.limit);
        const limitConverted = await this._convertAmountFx({
          amount: b.limit,
          sourceCurrency: budgetCurrency || "TRY",
          targetCurrency,
        });

        console.log('source currency : ' + budgetCurrency + ' target currency : ' + targetCurrency);

        // İstersen spentAmount / limitAmount / progress gibi alanları UI için netleştir:
        return {
          ...b,

          // response’ta hedef currency net olsun
          currency: targetCurrency,

          // bütçe limiti hedef currency'e çevrilmiş hali
          limit: limitConverted,

          // harcama hedef currency
          spent,
          spentAmount: spent,

          // opsiyonel yardımcılar (UI işi kolaylaşır)
          remaining: limitConverted - spent,
          progress: limitConverted > 0 ? spent / limitConverted : 0,
          percentage: limitConverted > 0 ? (spent / limitConverted) * 100 : 0,
        };
      })
    );

    return withSpent;
  }
}

module.exports = GetBudgets;