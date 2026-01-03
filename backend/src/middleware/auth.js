const { buildAuthModule } = require("../modules/auth");

const auth = buildAuthModule();

function extractBearerToken(req) {
  const header = req.headers.authorization || req.headers.Authorization;
  if (!header || typeof header !== "string") return null;

  const [type, token] = header.split(" ");
  if (!type || !token) return null;
  if (type.toLowerCase() !== "bearer") return null;

  return token;
}

const requireAuth = async (req, res, next) => {
  try {
    const token = extractBearerToken(req);
    const { userId } = await auth.verifyAccessToken.execute({ token });

    req.user = { userId };
    return next();
  } catch (e) {
    return res.status(401).json({ ok: false, error: e.message });
  }
};

module.exports = { requireAuth };
