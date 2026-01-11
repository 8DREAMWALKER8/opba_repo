// Kredi faiz oranlarını CSV’den okuyup filtreleyerek listeleyen / karşılaştırma verisi dönen API yerleri

const express = require("express");
const router = express.Router();
const fs = require("fs");
const path = require("path");

function parseCsv(content) {
  const lines = content.split(/\r?\n/).filter(Boolean);
  if (!lines.length) return [];

  const delimiter = lines[0].includes(";") ? ";" : ",";
  const headers = lines[0]
    .split(delimiter)
    .map((h) => h.replace(/^\uFEFF/, "").trim());

  return lines.slice(1).map((line) => {
    const cols = line.split(delimiter).map((c) => c.trim());
    const obj = {};
    headers.forEach((h, i) => (obj[h] = cols[i] ?? ""));
    return obj;
  });
}

let CACHE = { ts: 0, rows: [] };

function readRatesCsv() {
  const now = Date.now();
  if (now - CACHE.ts < 60_000 && CACHE.rows.length) return CACHE.rows;

  const filePath = path.join(
    process.cwd(),
    "src",
    "data",
    "opba_interest_rates.csv"
  );

  const raw = fs.readFileSync(filePath, "utf-8");
  const rows = parseCsv(raw);

  CACHE = { ts: now, rows };
  return rows;
}

function normalizeRows(rows) {
  return rows
    .map((r) => {
      const monthlyRate = Number(String(r.monthly_rate).replace(",", "."));
      if (!r.bank_name || !Number.isFinite(monthlyRate)) return null;

      return {
        bankName: r.bank_name,
        loanType: r.loan_type,
        currency: r.currency,
        termMonths: Number(r.term_months),
        monthlyRate,
        monthlyRatePercent: Math.round(monthlyRate * 10000) / 100,
        annualEffectiveRate: Number(r.annual_effective_rate),
        asOfMonth: r.as_of_month,
        source: r.source,
      };
    })
    .filter(Boolean);
}

router.get("/", (req, res) => {
  try {
    const {
      loan_type,
      currency,
      term_months,
      bank_name,
      sort = "asc",
    } = req.query;

    let items = normalizeRows(readRatesCsv());

    if (bank_name) {
      const b = bank_name.toLowerCase();
      items = items.filter(
        (x) => x.bankName.toLowerCase() === b
      );
    }

    if (loan_type) items = items.filter((x) => x.loanType === loan_type);
    if (currency) items = items.filter((x) => x.currency === currency);
    if (term_months)
      items = items.filter(
        (x) => x.termMonths === Number(term_months)
      );

    items.sort((a, b) =>
      sort === "desc"
        ? b.monthlyRatePercent - a.monthlyRatePercent
        : a.monthlyRatePercent - b.monthlyRatePercent
    );

    const chart = items.map((x) => ({
      label: x.bankName,
      value: x.monthlyRatePercent,
      termMonths: x.termMonths,
    }));

    res.json({
      ok: true,
      count: items.length,
      chart,
      items,
    });
  } catch (err) {
    res.status(500).json({
      ok: false,
      message: "INTEREST_RATES_ERROR",
      error: err.message,
    });
  }
});

router.get("/banks/:bankName/terms", (req, res) => {
  try {
    const { bankName } = req.params;
    const { loan_type = "consumer", currency = "TRY" } = req.query;

    const b = bankName.toLowerCase();

    const terms = normalizeRows(readRatesCsv())
      .filter((x) => x.bankName.toLowerCase() === b)
      .filter((x) => x.loanType === loan_type)
      .filter((x) => x.currency === currency)
      .sort((a, b2) => a.termMonths - b2.termMonths)
      .map((x) => ({
        termMonths: x.termMonths,
        monthlyRate: x.monthlyRate,
        monthlyRatePercent: x.monthlyRatePercent,
        annualEffectiveRate: x.annualEffectiveRate,
        asOfMonth: x.asOfMonth,
        source: x.source,
      }));

    if (!terms.length) {
      return res.status(404).json({
        ok: false,
        message: "TERMS_NOT_FOUND",
      });
    }

    res.json({
      ok: true,
      bankName,
      loanType: loan_type,
      currency,
      count: terms.length,
      terms,
    });
  } catch (err) {
    res.status(500).json({
      ok: false,
      message: "TERMS_ERROR",
      error: err.message,
    });
  }
});

module.exports = router;
