const { z } = require("zod");
const { SECURITY_QUESTIONS } = require("../../../utils/securityQuestions");
const { getQuestionText } = require("../../../utils/securityQuestions");

class UserController {
  constructor({ registerUser, loginStep1, loginStep2, getMe, updateUser }) {
    this.registerUser = registerUser;
    this.loginStep1 = loginStep1;
    this.loginStep2 = loginStep2;
    this.getMe = getMe;
    this.updateUser = updateUser;
  }

  register = async (req, res) => {
    try {
      /**
       * Şifre kuralları:
       * - min 8 karakter
       * - en az 1 küçük harf
       * - en az 1 büyük harf
       * - en az 1 noktalama / özel karakter
       */
      const PASSWORD_REGEX = /^(?=.*[a-z])(?=.*[A-Z])(?=.*[^\w\s]).{8,}$/;

      const schema = z
        .object({
          username: z.string().min(3),
          email: z.string().email(),

          // error code -> content.js'te çevrilecek
          phone: z.string().regex(/^\d{10,15}$/, "PHONE_INVALID_FORMAT"),

          //  Güç kontrolü sadece password'de -> tek hata gelsin
          password: z.string().regex(PASSWORD_REGEX, "PASSWORD_WEAK"),

          //  confirm sadece zorunlu (güç kontrolü burada yapılmıyor)
          passwordConfirm: z.string().min(1, "PASSWORD_CONFIRM_REQUIRED"),

          securityQuestionId: z.string().min(1),
          securityAnswer: z.string().min(1),
        })
        //  Eşleşme kontrolü (confirm alanına yaz)
        .refine((data) => data.password === data.passwordConfirm, {
          path: ["passwordConfirm"],
          message: "PASSWORD_CONFIRM_MISMATCH",
        });

      const input = schema.parse(req.body);

      // passwordConfirm usecase'e gitmez
      const { passwordConfirm, ...usecaseInput } = input;

      const out = await this.registerUser.execute(usecaseInput);
      return res.json({ ok: true, user: out });
    } catch (e) {
      e.statusCode = 400;
      throw e;
    }
  };

  loginStep1Handler = async (req, res) => {
    try {
      const schema = z.object({
        email: z.string().email(),
        password: z.string().min(1),
      });

      const input = schema.parse(req.body);
      const out = await this.loginStep1.execute(input);
      return res.json({ ok: true, ...out });
    } catch (e) {
      e.statusCode = 400;
      throw e;
    }
  };

  loginStep2Handler = async (req, res) => {
    try {
      const schema = z.object({
        userId: z.string().min(1),
        securityAnswer: z.string().min(1),
      });

      const input = schema.parse(req.body);
      const out = await this.loginStep2.execute(input);
      return res.json({ ok: true, ...out });
    } catch (e) {
      e.statusCode = 400;
      throw e;
    }
  };

  me = async (req, res) => {
    try {
      const out = await this.getMe.execute({ userId: req.user.userId });
      return res.json({ ok: true, user: out });
    } catch (e) {
      e.statusCode = 401;
      throw e;
    }
  };

  getSecurityQuestions = async (req, res) => {
    try {
      const lang = req.lang || "tr";
      const safeLang = lang === "en" ? "en" : "tr";

      const questions = SECURITY_QUESTIONS.map((q) => ({
        id: q.id,
        text: safeLang === "en" ? q.en : q.tr,
      }));

      return res.json({ ok: true, lang: safeLang, questions });
    } catch (e) {
      e.statusCode = 500;
      throw e;
    }
  };
  updateMe = async (req, res) => {
    try {
      const data = req.body || {};

      if (!data || Object.keys(data).length === 0) {
       const err = new Error("DATA_REQUIRED");
       err.statusCode = 400;
       throw err;
      }
      const user = await this.updateUser.execute({
        userId: req.user.userId,
        data: req.body,
      });

      const safeUser = {
        id: user.id,
        username: user.username,
        email: user.email,
        phone: user.phone,
        securityQuestionId: user.securityQuestionId,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      };

      return res.json({ ok: true, user: safeUser });
    } catch (e) {
      if (e?.message === "USER_NOT_FOUND") e.statusCode = 404;
      else if (e?.message === "DATA_REQUIRED") e.statusCode = 400;
      else if (!e?.statusCode) e.statusCode = 500;

      throw e;
    }
  };
}

module.exports = { UserController };
