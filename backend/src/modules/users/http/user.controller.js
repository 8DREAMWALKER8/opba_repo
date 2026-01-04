const { z } = require("zod");
const {
  SECURITY_QUESTIONS,
} = require("../../../utils/securityQuestions");

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
      const schema = z.object({
        username: z.string().min(3),
        email: z.string().email(),
        phone: z.string().regex(/^\d{10,15}$/, "phone must be digits (10-15)"),
        password: z.string().min(6),
        securityQuestionId: z.string().min(1),
        securityAnswer: z.string().min(1),
      });

      const input = schema.parse(req.body);
      const out = await this.registerUser.execute(input);
      res.json({ ok: true, user: out });
    } catch (e) {
      res.status(400).json({ ok: false, error: e.message });
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
      res.json({ ok: true, ...out });
    } catch (e) {
      res.status(400).json({ ok: false, error: e.message });
    }
  };

  loginStep2Handler = async (req, res) => {
    try {
      console.log("loginStep2Handler called with body:", req.body);
      const schema = z.object({
        userId: z.string().min(1),
        securityAnswer: z.string().min(1),
      });
      const input = schema.parse(req.body);
      const out = await this.loginStep2.execute(input);
      res.json({ ok: true, ...out });
    } catch (e) {
      res.status(400).json({ ok: false, error: e.message });
    }
  };

  me = async (req, res) => {
    try {
      const out = await this.getMe.execute({ userId: req.user.userId });
      res.json({ ok: true, user: out });
    } catch (e) {
      res.status(401).json({ ok: false, error: e.message });
    }
  };

  getSecurityQuestions = async (req, res) => {
    try {
      const lang = (req.query.lang || "tr").toLowerCase();
      const safeLang = lang === "en" ? "en" : "tr";
      const questions = SECURITY_QUESTIONS.map((q) => ({
        id: q.id,
        text: safeLang === "en" ? q.en : q.tr,
      }));

      res.json({ ok: true, lang: safeLang, questions });
    } catch (e) {
      res.status(500).json({ ok: false, error: e.message });
  }};

  updateMe = async (req, res) => {
    try {
      const user = await this.updateUser.execute({
        userId: req.user.userId,
        data: req.body,
      });
      console.log("User updated:", user);
      const safeUser = {
        id: user.id,
        username: user.username,
        email: user.email,
        phone: user.phone,
        securityQuestionId: user.securityQuestionId,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      };

      res.json({ ok: true, user: safeUser });
    } catch (e) {
      const msg = (e?.message || "").toLowerCase();

      if (msg.includes("not found")) {
        return res.status(404).json({ ok: false, error: e.message });
      }

      if (
        msg.includes("required") ||
        msg.includes("no valid fields") ||
        msg.includes("validation")
      ) {
        return res.status(400).json({ ok: false, error: e.message });
      }

      // beklenmeyen
      return res.status(500).json({ ok: false, error: e.message });
    }
  };
}

module.exports = { UserController };
