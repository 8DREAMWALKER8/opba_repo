// src/scripts/seedFromCsv.js
/* eslint-disable no-console */
const path = require("path");
const fs = require("fs");
const csv = require("csv-parser");
const mongoose = require("mongoose");
const crypto = require("crypto");

require("dotenv").config({ path: path.join(__dirname, "../../.env") });

// MODELLER (senin attığın modeller)
const User = require("../models/User");
const BankAccount = require("../models/BankAccount");
const Transaction = require("../models/Transaction");

// bcrypt varsa onu kullan, yoksa sha256 ile idare et (login bcrypt kullanıyorsa bcrypt kurman daha doğru)
let bcrypt = null;
try {
  bcrypt = require("bcryptjs");
} catch (_) {
  bcrypt = null;
}

console.log("=== SEED FROM CSV (MODEL-COMPAT) ===");
console.log("Node:", process.version);
console.log("MONGO_URI:", process.env.MONGO_URI ? "VAR" : "YOK");
console.log("bcrypt:", bcrypt ? "VAR" : "YOK (sha256 fallback)");

// CSV okuma
function readCsv(filePath) {
  return new Promise((resolve, reject) => {
    if (!fs.existsSync(filePath)) return reject(new Error(`CSV bulunamadı: ${filePath}`));

    const rows = [];
    fs.createReadStream(filePath)
      .on("error", reject)
      .pipe(csv())
      .on("data", (row) => rows.push(row))
      .on("end", () => resolve(rows));
  });
}

// -----------------------
// Helper'lar
// -----------------------
function extractOid(v) {
  if (v == null) return null;
  const s = String(v).trim();
  if (/^[a-fA-F0-9]{24}$/.test(s)) return s;

  let m = s.match(/['"]?\$oid['"]?\s*:\s*['"]([a-fA-F0-9]{24})['"]/);
  if (m) return m[1];

  m = s.match(/\{\s*'\$oid'\s*:\s*'([a-fA-F0-9]{24})'\s*\}/);
  if (m) return m[1];

  return null;
}

function toObjectId(v) {
  const hex = extractOid(v);
  if (!hex) return null;
  return new mongoose.Types.ObjectId(hex);
}

function extractDate(v) {
  if (v == null) return null;
  const s = String(v).trim();

  // ISO gibi geldiyse
  if (!s.startsWith("{") && !s.includes("$date")) {
    const d = new Date(s);
    return isNaN(d.getTime()) ? null : d;
  }

  // { "$date": "..." } veya { '$date': '...' }
  let m = s.match(/['"]?\$date['"]?\s*:\s*['"]([^'"]+)['"]/);
  if (m) {
    const d = new Date(m[1]);
    return isNaN(d.getTime()) ? null : d;
  }

  // { "$date": 1700000000000 }
  m = s.match(/['"]?\$date['"]?\s*:\s*(\d+)/);
  if (m) {
    const d = new Date(Number(m[1]));
    return isNaN(d.getTime()) ? null : d;
  }

  return null;
}

function toNum(v) {
  if (v == null || v === "") return null;
  const n = Number(v);
  return Number.isFinite(n) ? n : null;
}

function toStr(v) {
  if (v == null) return "";
  return String(v).trim();
}

function toBool(v) {
  if (v === true || v === false) return v;
  const s = String(v).trim().toLowerCase();
  if (s === "true" || s === "1") return true;
  if (s === "false" || s === "0") return false;
  return Boolean(v);
}

async function hashValue(raw) {
  const s = toStr(raw);
  if (!s) return null;

  if (bcrypt) {
    // bcryptjs ile hash
    const salt = await bcrypt.genSalt(10);
    return bcrypt.hash(s, salt);
  }

  // fallback: sha256
  return crypto.createHash("sha256").update(s).digest("hex");
}

// CSV’de gelen type’ı modele uydur (expense/income)
function normalizeTxType(v) {
  const s = toStr(v).toLowerCase();
  if (s === "expense" || s === "income") return s;

  // bazı CSV'lerde "gider/gelir" vb olabilir
  if (s === "gider") return "expense";
  if (s === "gelir") return "income";

  // default
  return "expense";
}

// -----------------------
// Main
// -----------------------
async function main() {
  const uri = process.env.MONGO_URI;
  if (!uri) throw new Error("MONGO_URI .env içinde yok!");

  // CSV path
  const USERS_CSV = path.join(__dirname, "../data/opba_users_200.csv");
  const ACC_CSV = path.join(__dirname, "../data/opba_bankaccounts_300.csv");
  const TX_CSV = path.join(__dirname, "../data/opba_transactions_500.csv");

  console.log("CSV paths:", { USERS_CSV, ACC_CSV, TX_CSV });

  console.log("MongoDB bağlanıyor...");
  await mongoose.connect(uri, {
    serverSelectionTimeoutMS: 8000,
    dbName: "opba",
  });

  console.log("MongoDB bağlandı ");
  console.log("HOST:", mongoose.connection.host);
  console.log("DB:", mongoose.connection.name);

  const usersRows = await readCsv(USERS_CSV);
  const accRows = await readCsv(ACC_CSV);
  const txRows = await readCsv(TX_CSV);

  console.log("CSV row counts:", {
    users: usersRows.length,
    bankaccounts: accRows.length,
    transactions: txRows.length,
  });

  // Temizlik
  console.log("Koleksiyonlar temizleniyor...");
  await Promise.all([
    Transaction.deleteMany({}),
    BankAccount.deleteMany({}),
    User.deleteMany({}),
  ]);
  console.log("Temizlendi");

  // -----------------------
  // USERS (MODEL UYUMLU)
  // Model required: username, email, phone, passwordHash, securityQuestionId, securityAnswerHash
  // CSV'den: username,email,phone,password,securityQuestion(or securityQuestionId),securityAnswer
  // -----------------------
  console.log("Users hazırlanıyor...");

  const userDocs = [];
  for (const u of usersRows) {
    // CSV kolon isimleri farklıysa burada fallback var:
    const username = toStr(u.username);
    const email = toStr(u.email);
    const phone = toStr(u.phone);

    const passwordRaw = u.password ?? u.passwordHash ?? u.password_hash ?? "";
    const secQ = u.securityQuestionId ?? u.securityQuestion ?? u.security_question_id ?? "q1";
    const secAraw = u.securityAnswer ?? u.securityAnswerHash ?? u.security_answer ?? "";

    // required alanlar boşsa bu satırı atla (seed patlamasın)
    if (!username || !email || !phone || !passwordRaw || !secQ || !secAraw) continue;

    userDocs.push({
      _id: toObjectId(u._id) || undefined,
      username,
      email: email.toLowerCase(),
      phone,
      passwordHash: await hashValue(passwordRaw),
      securityQuestionId: toStr(secQ),
      securityAnswerHash: await hashValue(secAraw),
      language: toStr(u.language) || "tr",
      currency: toStr(u.currency) || "TRY",
      theme: toStr(u.theme) || "light",
      // timestamps true zaten otomatik basar; CSV’den basmak istersen schema’da ayrıca izin vermen gerekir
    });
  }

  console.log("Users hazırlanmış:", userDocs.length);

  try {
    const inserted = await User.insertMany(userDocs, { ordered: false });
    console.log("Users insert OK :", inserted.length);
  } catch (err) {
    console.error("Users insert HATA :", err?.message);
    if (err?.writeErrors?.length) {
      console.error("Örnek writeError:", err.writeErrors[0]?.errmsg || err.writeErrors[0]);
    }
    throw err;
  }

  // -----------------------
  // BANK ACCOUNTS (MODEL UYUMLU)
  // required: userId, bankName, accountName, cardNumber
  // CSV eskiden: bankName, cardNumber, cardHolderName, expiryDate, cardNumber, balance, currency...
  // Biz accountName'i CSV’de varsa alırız; yoksa cardHolderName ya da "Main Account"
  // -----------------------
  console.log("BankAccounts hazırlanıyor...");

  const accDocs = [];
  for (const a of accRows) {
    const userId = toObjectId(a.userId);
    const bankName = toStr(a.bankName);
    const cardNumber = toStr(a.cardNumber);

    const accountName =
      toStr(a.accountName) ||
      toStr(a.account_type) ||
      toStr(a.cardHolderName) ||
      "Main Account";

    if (!userId || !bankName || !cardNumber || !accountName) continue;
    accDocs.push({
      _id: toObjectId(a._id) || undefined,
      userId,
      bankName,
      cardHolderName,
      cardNumber,
      currency: toStr(a.currency) || "TRY",
      balance: toNum(a.balance) ?? 0,
      isActive: a.isActive != null ? toBool(a.isActive) : true,
      lastSyncedAt: extractDate(a.lastSyncedAt),
      source: toStr(a.source) || "mock",
    });
  }

  console.log("BankAccounts hazırlanmış:", accDocs.length);

  try {
    const inserted = await BankAccount.insertMany(accDocs, { ordered: false });
    console.log("BankAccounts insert OK :", inserted.length);
  } catch (err) {
    console.error("BankAccounts insert HATA :", err?.message);
    if (err?.writeErrors?.length) {
      console.error("Örnek writeError:", err.writeErrors[0]?.errmsg || err.writeErrors[0]);
    }
    throw err;
  }

  // -----------------------
  // TRANSACTIONS (MODEL UYUMLU)
  // required: userId, accountId, type(expense/income), amount, description, occurredAt
  // CSV eskiden: date alanı vardı -> occurredAt'e map ediyoruz
  // -----------------------
  console.log("Transactions hazırlanıyor...");

  const txDocs = [];
  for (const t of txRows) {
    const userId = toObjectId(t.userId);
    const accountId = toObjectId(t.accountId);
    const type = normalizeTxType(t.type);
    const amount = toNum(t.amount);
    const description = toStr(t.description);
    const occurredAt = extractDate(t.occurredAt) || extractDate(t.date); // CSV'de date varsa

    if (!userId || !accountId || !type || amount == null || !description || !occurredAt) continue;

    // category enum dışına çıkarsa default other’a çek
    const categoryAllowed = new Set([
      "market",
      "transport",
      "food",
      "bills",
      "entertainment",
      "health",
      "education",
      "other",
    ]);
    const category = categoryAllowed.has(toStr(t.category)) ? toStr(t.category) : "other";

    txDocs.push({
      _id: toObjectId(t._id) || undefined,
      userId,
      accountId,
      type,
      amount,
      currency: toStr(t.currency) || "TRY",
      category,
      description,
      occurredAt,
      source: toStr(t.source) || "mock",
    });
  }

  console.log("Transactions hazırlanmış:", txDocs.length);

  try {
    const inserted = await Transaction.insertMany(txDocs, { ordered: false });
    console.log("Transactions insert OK :", inserted.length);
  } catch (err) {
    console.error("Transactions insert HATA :", err?.message);
    if (err?.writeErrors?.length) {
      console.error("Örnek writeError:", err.writeErrors[0]?.errmsg || err.writeErrors[0]);
    }
    throw err;
  }

  //  Son kontrol
  const [uCount, aCount, tCount] = await Promise.all([
    User.countDocuments(),
    BankAccount.countDocuments(),
    Transaction.countDocuments(),
  ]);
  console.log("FINAL COUNTS :", { users: uCount, bankaccounts: aCount, transactions: tCount });

  await mongoose.disconnect();
  console.log("Mongo bağlantısı kapandı.");
}

main().catch(async (e) => {
  console.error("Seed hata:", e);
  try {
    await mongoose.disconnect();
  } catch (_) {}
  process.exit(1);
});
