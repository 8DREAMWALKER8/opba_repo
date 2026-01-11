/**
 * Bu dosya, kredi hesaplama işlemleri için kullanılan API endpoint’lerini tanımlar.
 * Banka bazlı faiz oranlarını CSV dosyasından okur,
 * aylık taksit, toplam ödeme ve toplam faiz tutarını hesaplar.
 * Hesaplama işlemi sunucu tarafında yapılır ve sonuçlar
 * istemciye JSON formatında döndürülür.
 */

const express = require("express");
const router = express.Router();
const fs = require("fs");
const path = require("path");

const { t } = require("../shared/content");

function parseCsv(content) {
  const lines = content.split(/\r?\n/).filter(Boolean);
  if (lines.length === 0) return [];

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

  const filePath = path.join(process.cwd(), "src", "data", "opba_interest_rates.csv");
  const raw = fs.readFileSync(filePath, "utf-8");
  const rows = parseCsv(raw);

  CACHE = { ts: now, rows };
  return rows;
}

function calcLoan({ principal, months, monthlyRate }) {
  const P = principal;
  const n = months;
  const r = monthlyRate; 

  let monthlyPayment;
  if (r === 0) monthlyPayment = P / n;
  else {
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
        message: t(req, "errors.BANK_NAME_REQUIRED"),
      });

    if (!Number.isFinite(term) || term <= 0)
      return res.status(400).json({
        ok: false,
        message: t(req, "errors.TERM_MONTHS_INVALID"),
      });

    if (!Number.isFinite(P) || P <= 0)
      return res.status(400).json({
        ok: false,
        message: t(req, "errors.PRINCIPAL_INVALID"),
      });

    const rows = readRatesCsv();
    const bankLower = bank.toLowerCase();

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
        message: t(req, "errors.RATE_NOT_FOUND"),
        debug: { bank_name: bank, loan_type, currency, term_months: term },
      });
    }

    const monthlyRate = Number(String(match.monthly_rate).replace(",", ".")); 
    if (!Number.isFinite(monthlyRate)) {
      return res.status(500).json({
        ok: false,
        message: t(req, "errors.MONTHLY_RATE_PARSE_ERROR"),
      });
    }

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
        monthly_rate_percent: Math.round(monthlyRate * 100000) / 1000, 
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
      message: t(req, "errors.CALC_ERROR"),
      error: err.message,
    });
  }
});

module.exports = router;
