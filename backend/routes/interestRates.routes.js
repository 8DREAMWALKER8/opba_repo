/*
CSV içeriğini satır satır okur.
Başlıkları (header) key olarak kullanır.
Her satırı bir obje haline getirir.
*/
const express = require("express");
const router = express.Router();
const fs = require("fs");
const path = require("path");

//  CSV DOSYASINI PARSE ETME
// CSV içeriğini satır satır okur.
// Başlıkları (header) key olarak kullanır.
// Her satırı bir obje haline getirir.
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

 //CSV OKUMA + CACHE
 //CSV dosyası her istekte tekrar okunmasın diye 60 saniyelik cache kullanılır.

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

//  VERİ NORMALIZE
// CSV'den gelen string değerleri sayıya çevirir.

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

 // ANA LİSTE ENDPOINT
 // Grafik (chart) + banka kartları için kullanılır.

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
      message: "Interest rates error",
      error: err.message,
    });
  }
});

// BANKA DETAY – VADESİNE GÖRE FAİZLER
// GET /api/interest-rates/banks/:bankName/terms
// Seçilen bankanın tüm vadelerini listeler.
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
        message: "No terms found",
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
      message: "Terms error",
      error: err.message,
    });
  }
});

module.exports = router;
