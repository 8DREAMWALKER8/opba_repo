// Bu dosya, sandbox CSV dosyalarındaki verileri MongoDB veritabanına test (seed) verisi olark otomatik şekilde eklemek için kullanılır.

const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "../../.env") });

const fs = require("fs");
const csv = require("csv-parser");
const mongoose = require("mongoose");
const crypto = require("crypto");


// Kullanılan MongoDB modelleri
const User = require("../models/User");
const UserProfile = require("../models/UserProfile");
const BankAccount = require("../models/BankAccount");
const Transaction = require("../models/Transaction");

console.log("=== SEED DOSYASI ÇALIŞTI ===");
console.log("Node:", process.version);
console.log("MONGO_URI:", process.env.MONGO_URI ? "VAR" : "YOK");

// CSV Okuma Fonksiyonu
// Verilen CSV dosyasını satır satır okuyup array olarak geri döndürür.
function readCsv(filePath) {
  return new Promise((resolve, reject) => {
    if (!fs.existsSync(filePath)) {
      return reject(new Error(`CSV bulunamadı: ${filePath}`));
    }

    const rows = [];
    fs.createReadStream(filePath)
      .on("error", reject)
      .pipe(csv())
      .on("data", (row) => rows.push(row))
      .on("end", () => resolve(rows));
  });
}
// SHA256 Hash Fonksiyonu
function sha256(text) {
  return crypto.createHash("sha256").update(String(text)).digest("hex");
}

//  BankAccount modelinde; userId + iban unique olduğu için her hesap için farklı IBAN üretmek zorundayız.
function fakeIbanTR(userId, bankName, idx = 1) {
  const base =
    String(userId).padStart(6, "0") +
    sha256(bankName).slice(0, 10) +
    String(idx).padStart(4, "0"); // 2 yerine 4 hane daha güvenli

  return "TR" + "00" + base.replace(/[a-f]/g, "1").slice(0, 24);
}

// Hesap Adı Belirleme
function pickAccountName(currency) {
  if (currency === "USD") return "Vadesiz USD";
  if (currency === "EUR") return "Vadesiz EUR";
  return "Vadesiz TL";
}

function randomDesc(paymentType) {
  const map = {
    AA: ["Migros", "A101", "BİM", "Şok"],
    AB: ["Starbucks", "Kahve Dünyası", "Gloria Jeans"],
    AC: ["Getir", "Yemeksepeti", "Trendyol Go"],
    AD: ["İstanbulkart", "Metro", "Taksi"],
    AE: ["Elektrik Faturası", "Su Faturası", "İnternet"],
  };
  const arr = map[paymentType] || ["Harcama", "Market", "Ödeme"];
  return arr[Math.floor(Math.random() * arr.length)];
}

// Ana seed fonksiyonu
async function main() {
  console.log("=== main başladı ===");

  if (!process.env.MONGO_URI) {
    throw new Error("MONGO_URI .env içinde yok!");
  }

  console.log("=== MongoDB'ye bağlanılıyor... ===");
  await mongoose.connect(process.env.MONGO_URI, {
    serverSelectionTimeoutMS: 5000,
    connectTimeoutMS: 5000,
    socketTimeoutMS: 5000,
  });
  console.log("MongoDB bağlandı");

  const usersPath = path.join(__dirname, "../data/opba_users_sandbox_email.csv");
  const accPath = path.join(__dirname, "../data/opba_bank_accounts_sandbox_email.csv");
  const txPath = path.join(__dirname, "../data/opba_transactions_sandbox_email.csv");

  console.log("usersPath:", usersPath);
  console.log("accPath:", accPath);
  console.log("txPath:", txPath);

  console.log("usersCsv okunuyor...");
  const usersCsv = await readCsv(usersPath);
  console.log("usersCsv:", usersCsv.length);

  console.log("accCsv okunuyor...");
  const accCsv = await readCsv(accPath);
  console.log("accCsv:", accCsv.length);

  console.log("txCsv okunuyor...");
  const txCsvAll = await readCsv(txPath);
  console.log("txCsvAll:", txCsvAll.length);

  const txCsv = txCsvAll.slice(0, 5000);
  console.log("txCsv limited:", txCsv.length);

  console.log("=== Koleksiyonlar temizleniyor... ===");
  await Promise.all([
    UserProfile.deleteMany({}),
    BankAccount.deleteMany({}),
    Transaction.deleteMany({}),
    User.deleteMany({ email: /@sandbox\.opba\.com$/ }),
  ]);
  console.log("Temizlendi");

  // 1) User Profile 
  console.log("UserProfile insertMany...");
  const userProfiles = usersCsv.map((u) => ({
    userId: Number(u.user_id),
    username: u.username,
    email: u.email,
    firstName: u.first_name,
    lastName: u.last_name,
    fullName: u.full_name,
    customerAge: Number(u.customer_age),
    income: Number(u.income),
    employmentStatus: u.employment_status,
    housingStatus: u.housing_status,
    creditRiskScore: Number(u.credit_risk_score),
    bankMonthsCount: Number(u.bank_months_count),
    hasOtherCards: Number(u.has_other_cards),
    emailIsFree: Number(u.email_is_free),
  }));
  await UserProfile.insertMany(userProfiles);
  console.log("UserProfile basıldı");

  // 2) Auth User oluşturma
  //  Login sistemi için gerekli User kayıtları mock bilgilerle oluşturulur.
  console.log("Auth User oluşturuluyor...");
  const userIdToMongoId = new Map();

  for (const u of usersCsv) {
    const csvUserId = Number(u.user_id);
    const username = u.username;

    const baseEmail = u.email;
    const email = baseEmail.replace("@", `+${csvUserId}@`);

    const created = await User.create({
      username,
      email,
      phone: "5550000000",

      passwordHash: sha256("opba12345"),
      resetCodeHash: null,
      resetCodeExpiresAt: null,
      resetCodeAttempts: 0,

      securityQuestionId: "q1",
      securityAnswerHash: sha256("ankara"),

      language: "tr",
      currency: "TRY",
      theme: "light",
    });

    userIdToMongoId.set(csvUserId, created._id);
  }
  console.log("Auth User basıldı:", userIdToMongoId.size);


  console.log("BankAccount basılıyor...");

  // Bank Account
  const userMongoToAccountIds = new Map();

  const ibanCounter = new Map();

  for (const a of accCsv) {
    const csvUserId = Number(a.user_id);
    const mongoUserId = userIdToMongoId.get(csvUserId);
    if (!mongoUserId) continue;

    const bankName = a.bank_name;
    const currency = a.currency || "TRY";
    const accountName = pickAccountName(currency);

    const counterKey = `${mongoUserId}-${bankName}`;
    const nextIdx = (ibanCounter.get(counterKey) || 0) + 1;
    ibanCounter.set(counterKey, nextIdx);

    const iban = fakeIbanTR(csvUserId, bankName, nextIdx);

    const createdAcc = await BankAccount.create({
      userId: mongoUserId,
      bankName,
      accountName,
      iban,
      currency,
      balance: Number(a.balance),
      source: "mock",
    });

    const key = String(mongoUserId);
    if (!userMongoToAccountIds.has(key)) userMongoToAccountIds.set(key, []);
    userMongoToAccountIds.get(key).push(createdAcc._id);
  }
  console.log("BankAccount basıldı:", accCsv.length);

  // 4) Transaction 
  console.log("Transaction hazırlanıyor...");
  const txDocs = [];
  const now = Date.now();

  for (const t of txCsv) {
    const csvUserId = Number(t.user_id);
    const mongoUserId = userIdToMongoId.get(csvUserId);
    if (!mongoUserId) continue;

    const accList = userMongoToAccountIds.get(String(mongoUserId)) || [];
    if (accList.length === 0) continue;

    const accountId = accList[Math.floor(Math.random() * accList.length)];
    const amount = Number(t.amount_try);

    const type = Math.random() < 0.85 ? "expense" : "income";
    const description = randomDesc(t.payment_type);
    const occurredAt = new Date(
      now - Math.floor(Math.random() * 30) * 24 * 60 * 60 * 1000
    );

    txDocs.push({
      userId: mongoUserId,
      accountId,
      type,
      amount: Math.abs(amount),
      currency: t.currency || "TRY",
      category: "other",
      description,
      occurredAt,
      source: "mock",
    });
  }

  console.log("Transaction docs hazır:", txDocs.length);
  console.log("Transaction insertMany (batch) başlıyor...");

  const BATCH = 2000;
  for (let i = 0; i < txDocs.length; i += BATCH) {
    const chunk = txDocs.slice(i, i + BATCH);
    await Transaction.insertMany(chunk, { ordered: false });
    console.log(`Transactions: ${Math.min(i + BATCH, txDocs.length)}/${txDocs.length}`);
  }

  console.log("Seed tamam:", {
    userProfiles: userProfiles.length,
    users: usersCsv.length,
    bankAccounts: accCsv.length,
    transactions: txDocs.length,
  });

  await mongoose.disconnect();
  console.log("MongoDB bağlantısı kapandı");
}

main().catch(async (e) => {
  console.error("Seed hata:", e);
  try {
    await mongoose.disconnect();
  } catch {}
  process.exit(1);
});
