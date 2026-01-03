const { z } = require("zod");

class UserController {
  constructor({ registerUser, loginStep1, loginStep2, getMe }) {
    this.registerUser = registerUser;
    this.loginStep1 = loginStep1;
    this.loginStep2 = loginStep2;
    this.getMe = getMe;
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
}

module.exports = { UserController };
