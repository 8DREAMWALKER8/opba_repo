const { z } = require("zod");

// TR IBAN: "TR" + 24 digit => toplam 26 char
const TR_IBAN_REGEX = /^TR\d{24}$/;

// Banka ismini sadece bu 3'ü olsun istiyorsan
const ALLOWED_BANKS = ["Akbank", "İş Bankası", "Garanti"];

const CreateAccountSchema = z
  .object({
    bankName: z
      .string()
      .trim()
      .min(1, "BANK_NAME_REQUIRED")
      .refine((v) => ALLOWED_BANKS.includes(v), { message: "BANK_NAME_INVALID" }),

    accountName: z.string().trim().min(1, "ACCOUNT_NAME_REQUIRED"),

    iban: z
      .string()
      .min(1, "IBAN_REQUIRED")
      .transform((v) => v.replace(/\s+/g, "").toUpperCase())
      .refine((v) => TR_IBAN_REGEX.test(v), { message: "IBAN_INVALID_FORMAT" }),

    currency: z.enum(["TRY", "USD", "EUR"]).optional(),
    balance: z.number().nonnegative("BALANCE_INVALID").optional(),
    source: z.enum(["manual", "mock"]).optional(),
  })
  .strict();

module.exports = ({ listAccounts, createAccount, deactivateAccount }) => ({
  list: async (req, res) => {
    const userId = req.user.userId || req.user._id || req.user.id;
    const accounts = await listAccounts.execute({ userId });
    res.json({ ok: true, accounts });
  },

  create: async (req, res) => {
    try {
      const userId = req.user.userId || req.user._id || req.user.id;

      //  doğrulama + normalize (IBAN boşlukları siler, TR... yapar)
      const parsed = CreateAccountSchema.parse(req.body);

      //  usecase'e aynı şekilde yolla (senin mevcut imzanı bozmadım)
      const account = await createAccount.execute({ userId, data: parsed });

      res.status(201).json({ ok: true, account });
    } catch (e) {
      // zod hataları errorHandler'da 400 + issues olarak dönecek
      e.statusCode = 400;
      throw e;
    }
  },

  deactivate: async (req, res) => {
    const userId = req.user.userId || req.user._id || req.user.id;
    const { id } = req.params;
    const account = await deactivateAccount.execute({ userId, accountId: id });
    res.json({ ok: true, account });
  },
});
