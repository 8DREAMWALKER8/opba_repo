/*
 Controller, HTTP işlerini (req/res) yönetir. doğrulama , parametre okuma ve userId çıkarma yapar
*/
const { z } = require("zod");

const CARD_NUMBER_REGEX = /^\d{16}$/;

const ALLOWED_BANKS = ["Akbank", "İş Bankası", "Garanti BBVA"];

const CreateAccountSchema = z
  .object({
    bankName: z
      .string()
      .trim()
      .min(1, "BANK_NAME_REQUIRED")
      .refine((v) => ALLOWED_BANKS.includes(v), { message: "BANK_NAME_INVALID" }),

    cardHolderName: z.string().trim().min(1, "CARD_HOLDER_NAME_REQUIRED"),

    cardNumber: z
      .string()
      .min(1, "CARD_NUMBER_REQUIRED")
      .transform((v) => v.replace(/\s+/g, "").replace(/[^\d]/g, ""))
      .refine((v) => CARD_NUMBER_REGEX.test(v), {
        message: "CARD_NUMBER_INVALID_FORMAT",
      }),
    description: z.string().max(30, "DESCRIPTION_TOO_LONG").optional(),
    currency: z.enum(["TRY", "USD", "EUR", "GBP"]).optional(),
    balance: z.number().nonnegative("BALANCE_INVALID").optional(),
    source: z.enum(["manual", "mock"]).optional(),
  })
  .strict();

module.exports = ({ listAccounts, createAccount, deactivateAccount, updateAccount}) => ({
  list: async (req, res) => {
    const userId = req.user.userId || req.user._id || req.user.id;
    const currency = req.query.currency; 
    console.log("Currency in controller:", req.query);
    const accounts = await listAccounts.execute({
      userId,
      selectedCurrency: currency,
    });
    res.json({ ok: true, accounts });
  },

  create: async (req, res) => {
    try {
      const userId = req.user.userId || req.user._id || req.user.id;

      const parsed = CreateAccountSchema.parse(req.body);

      const account = await createAccount.execute({ userId, data: parsed });

      res.status(201).json({ ok: true, account });
    } catch (e) {
      console.log("Error in create account controller:", e);
      e.statusCode = 400;
      throw e;
    }
  },

  update: async (req, res) => {
    try {
      const userId = req.user.userId || req.user._id || req.user.id;
      const id = req.params.id ?? req.params.accountId;
      console.log('ilk id ' + id)
      if (!id) {
        const e = new Error("ACCOUNT_ID_REQUIRED");
        e.statusCode = 400;
        throw e;
      }

      const body = { ...req.body };
      if (typeof body.balance === "string" && body.balance.trim() !== "") {
        const n = Number(body.balance);
        body.balance = Number.isFinite(n) ? n : body.balance; 
      }

      const account = await updateAccount.execute({
        userId,
        accountId: id,
        data: body,
      });

      res.json({ ok: true, account });
    } catch (e) {
      console.log(e);
      e.statusCode = e.statusCode || 400;
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