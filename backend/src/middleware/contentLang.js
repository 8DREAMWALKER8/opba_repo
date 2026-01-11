const { getLangFromReq } = require("../shared/content");

function contentLang(req, _res, next) {
  req.lang = getLangFromReq(req);
  next();
}

module.exports = { contentLang };
