const router = require("express").Router();

module.exports = (controller) => {
  router.get("/", controller.getLatest);
  router.post("/sync", controller.syncNow);
  return router;
};
