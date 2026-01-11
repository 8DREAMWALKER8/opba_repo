/**
 * Bu sınıf, kullanıcıya ait banka hesabı bilgilerini güncellemek için kullanılır.
 * Gelen veriyi Zod ile doğrular, hesabın kullanıcıya ait olduğunu kontrol eder
 * ve hesap pasifse güncellemeye izin vermez.
 * Zod,veri doğrulama ve tip tanımlama kütüphanesidir.
 */

const { z } = require("zod");

const ALLOWED_BANKS = ["Akbank", "İş Bankası", "Garanti BBVA"];

const UpdateAccountSchema = z
  .object({
    bankName: z
      .string()
      .trim()
      .min(1, "BANK_NAME_REQUIRED")
      .optional()
      .refine((v) => (v ? ALLOWED_BANKS.includes(v) : true), {
        message: "BANK_NAME_INVALID",
      }),

    cardHolderName: z.string().trim().min(1, "CARD_HOLDER_REQUIRED").optional(),

    cardNumber: z
      .string()
      .trim()
      .transform((v) => v.replace(/\s+/g, "")) 
      .refine((v) => /^\d{16}$/.test(v), { message: "CARD_NUMBER_INVALID" })
      .optional(),

    description: z.string().trim().max(80, "DESCRIPTION_TOO_LONG").optional(),

    currency: z.enum(["TRY", "USD", "EUR", "GBP"]).optional(),

    balance: z.number().finite().nonnegative("BALANCE_INVALID").optional(),

    expiryDate: z
      .string()
      .trim()
      .refine((v) => /^(0[1-9]|1[0-2])\/\d{4}$/.test(v), {
        message: "EXPIRY_DATE_INVALID",
      })
      .optional(),

    accountName: z.string().trim().min(1, "ACCOUNT_NAME_REQUIRED").optional(),
    iban: z.string().trim().optional(),
  })
  .strict();

class UpdateAccount {
  constructor({ repo }) {
    if (!repo) throw new Error("ACCOUNT_REPO_REQUIRED");
    this.repo = repo;
  }

  async execute({ userId, accountId, data }) {
    if (!userId) {
      const e = new Error("UNAUTHORIZED");
      e.statusCode = 401;
      throw e;
    }
    if (!accountId) {
      const e = new Error("ACCOUNT_ID_REQUIRED");
      e.statusCode = 400;
      throw e;
    }

    const parsed = UpdateAccountSchema.parse(data);

    if (parsed.accountName && !parsed.cardHolderName) {
      parsed.cardHolderName = parsed.accountName;
    }
    if (parsed.iban && !parsed.cardNumber) {
      const digits = String(parsed.iban).replace(/\D/g, "");
      if (digits.length === 16) parsed.cardNumber = digits;
    }

    console.log("repo öncesi id " + accountId);

    let existing = null;
    if (typeof this.repo.findByIdForUser === "function") {
      existing = await this.repo.findByIdForUser({ id: accountId, userId });
    } else {
      existing = await this.repo.findById(accountId);
      if (existing && String(existing.userId) !== String(userId)) {
        const e = new Error("FORBIDDEN");
        e.statusCode = 403;
        throw e;
      }
    }

    if (!existing) {
      const e = new Error("ACCOUNT_NOT_FOUND");
      e.statusCode = 404;
      throw e;
    }
    if (existing.isActive === false) {
      const e = new Error("ACCOUNT_INACTIVE");
      e.statusCode = 409;
      throw e;
    }

    const patch = {};
    if (parsed.bankName !== undefined) patch.bankName = parsed.bankName;
    if (parsed.cardHolderName !== undefined)
      patch.cardHolderName = parsed.cardHolderName;
    if (parsed.cardNumber !== undefined) patch.cardNumber = parsed.cardNumber;
    if (parsed.description !== undefined) patch.description = parsed.description;
    if (parsed.currency !== undefined) patch.currency = parsed.currency;
    if (parsed.balance !== undefined) patch.balance = parsed.balance;
    if (parsed.expiryDate !== undefined) patch.expiryDate = parsed.expiryDate;

    if (Object.keys(patch).length === 0) return existing;

    patch.updatedAt = new Date();

    if (typeof this.repo.updateByIdForUser === "function") {
      return await this.repo.updateByIdForUser({
        id: accountId,
        userId,
        patch,
      });
    }

    return await this.repo.updateById(accountId, patch);
  }
}

module.exports = UpdateAccount;