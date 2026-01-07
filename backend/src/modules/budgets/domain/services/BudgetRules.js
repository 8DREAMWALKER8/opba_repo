class BudgetRules {
  static getMonthlyRange(date) {
    const d = new Date(date);
    const from = new Date(d.getFullYear(), d.getMonth(), 1, 0, 0, 0, 0);
    const to = new Date(d.getFullYear(), d.getMonth() + 1, 1, 0, 0, 0, 0);
    return { from, to };
  }

  static isBreached(spent, limit) {
    return Number(spent) > Number(limit);
  }

  // %80 eşiği
  static getNearLimitThreshold(limit, ratio = 0.8) {
    return Number(limit) * ratio;
  }

  // Eşik “aşıldı mı?” (önce/sonra karşılaştırması)
  static crossedUpward(before, after, threshold) {
    if (!Number.isFinite(before) || !Number.isFinite(after) || !Number.isFinite(threshold)) return false;
    return before < threshold && after >= threshold;
  }

  static buildExceededMessage({ category, limit, spent, currency }) {
    return `${category} bütçesi aşıldı. Limit: ${limit} ${currency}, Harcama: ${spent} ${currency}`;
  }

  // %80 mesajı
  static buildNearLimitMessage({ category, limit, spent, currency, threshold }) {
    return `${category} bütçesi %80 sınırına yaklaştı. Limit: ${limit} ${currency}, Harcama: ${spent} ${currency} (Eşik: ${threshold} ${currency})`;
  }
}

module.exports = BudgetRules;
