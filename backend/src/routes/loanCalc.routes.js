// Bu dosya, faiz oranlarını kullanarak kredi taksit hesabı yapar.
const express = require("express");
const router = express.Router();
const fs = require("fs");
const path = require("path");

// ✅ content helper
const { t } = require("../shared/content");

// CSV'yi basit şekilde parse etmek için helper.
function parseCsv(content) {
  const lines = content.split(/\r?\n/).filter(Boolean);
  if (lines.length === 0) return [];

  const delimiter = lines[0].includes(";") ? ";" : ",";
  const headers = lines[0]
    .split(delimiter)
    .map((h) => h.replace(/^\uFEFF/, "").trim());

  // Her satırı başlıklara göre objeye çeviriyoruz {bank_name: "...", term_months: "..."}
  return lines.slice(1).map((line) => {
    const cols = line.split(delimiter).map((c) => c.trim());
    const obj = {};
    headers.forEach((h, i) => (obj[h] = cols[i] ?? ""));
    return obj;
  });
}

// 60 saniye içinde tekrar istek gelirse aynı veriyi kullanıyoruz.
let CACHE = { ts: 0, rows: [] };
function readRatesCsv() {
  const now = Date.now();
  if (now - CACHE.ts < 60_000 && CACHE.rows.length) return CACHE.rows;

  const filePath = path.join(process.cwd(), "src", "data", "opba_interest_rates.csv");
  const raw = fs.readFileSync(filePath, "utf-8");
  const rows = parseCsv(raw);

  CACHE = { ts: now, rows };
  return rows;
}

// Annuiteli kredi hesabı (bankaların klasik taksit hesabı).
// Formül ile aylık taksit, toplam ödeme ve toplam faiz hesaplanır.
function calcLoan({ principal, months, monthlyRate }) {
  const P = principal;
  const n = months;
  const r = monthlyRate; // 0.03162 gibi

  let monthlyPayment;
  if (r === 0) monthlyPayment = P / n;
  else {
    // annuite formülü
    const pow = Math.pow(1 + r, n);
    monthlyPayment = (P * r * pow) / (pow - 1);
  }

  const totalPayment = monthlyPayment * n;
  const totalInterest = totalPayment - P;

  const round2 = (x) => Math.round(x * 100) / 100;

  return {
    monthlyPayment: round2(monthlyPayment),
    totalPayment: round2(totalPayment),
    totalInterest: round2(totalInterest),
  };
}

/**
 * POST /api/loan/calc
 * Bu endpoint kredi hesaplar:
 * Frontend bankayı, vade ayını ve ana parayı gönderir.
 * Backend CSV'den ilgili bankanın ilgili vadedeki monthly_rate değerini bulur sonra annuite formülüyle taksit/total/faiz hesaplayıp döner.
 */

router.post("/calc", (req, res) => {
  try {
    const {
      bank_name,
      loan_type = "consumer",
      currency = "TRY",
      term_months,
      principal,
    } = req.body;

    const bank = String(bank_name || "").trim();
    const term = Number(term_months);
    const P = Number(principal);

    if (!bank)
      return res.status(400).json({
        ok: false,
        message: t(req, "errors.BANK_NAME_REQUIRED", "bank_name required"),
      });

    if (!Number.isFinite(term) || term <= 0)
      return res.status(400).json({
        ok: false,
        message: t(req, "errors.TERM_MONTHS_INVALID", "term_months invalid"),
      });

    if (!Number.isFinite(P) || P <= 0)
      return res.status(400).json({
        ok: false,
        message: t(req, "errors.PRINCIPAL_INVALID", "principal invalid"),
      });

    const rows = readRatesCsv();
    const bankLower = bank.toLowerCase();

    // CSV'de: banka + kredi türü + para birimi + vade eşleşen satırı buluyoruz
    const match = rows.find((r) => {
      const bn = String(r.bank_name || "").toLowerCase();
      return (
        bn === bankLower &&
        String(r.loan_type) === String(loan_type) &&
        String(r.currency) === String(currency) &&
        Number(r.term_months) === term
      );
    });

    if (!match) {
      return res.status(404).json({
        ok: false,
        message: t(req, "errors.RATE_NOT_FOUND", "rate not found for given filters"),
        debug: { bank_name: bank, loan_type, currency, term_months: term },
      });
    }

    const monthlyRate = Number(String(match.monthly_rate).replace(",", ".")); // 0.03162
    if (!Number.isFinite(monthlyRate)) {
      return res.status(500).json({
        ok: false,
        message: t(req, "errors.MONTHLY_RATE_PARSE_ERROR", "monthly_rate parse error"),
      });
    }

    // Kredi sonuçlarını hesapla
    const result = calcLoan({ principal: P, months: term, monthlyRate });

    return res.json({
      ok: true,
      input: {
        bank_name: bank,
        loan_type,
        currency,
        term_months: term,
        principal: P,
      },
      rate: {
        monthly_rate: monthlyRate,
        monthly_rate_percent: Math.round(monthlyRate * 100000) / 1000, // ör: 3.162
        annual_effective_rate: match.annual_effective_rate
          ? Number(match.annual_effective_rate)
          : null,
        as_of_month: match.as_of_month,
        source: match.source,
      },
      result,
    });
  } catch (err) {
    return res.status(500).json({
      ok: false,
      message: t(req, "errors.CALC_ERROR", "calc error"),
      error: err.message,
    });
  }
});

module.exports = router;
