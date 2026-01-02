const router = require("express").Router();

module.exports = ({ controller, protect }) => {
  router.get("/", protect, controller.list);
  router.post("/", protect, controller.create);
  router.delete("/:id", protect, controller.deactivate);
  return router;
};
