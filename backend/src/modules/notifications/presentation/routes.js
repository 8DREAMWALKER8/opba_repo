const router = require("express").Router();

module.exports = ({ controller, protect }) => {
  router.get("/", protect, controller.getMine);
  router.patch("/:id/read", protect, controller.markRead);
  router.patch("/read-all", protect, controller.markAllRead);
  return router;
};
