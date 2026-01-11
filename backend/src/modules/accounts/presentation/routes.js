/*
 Bu dosya endpoint’leri tanımlar ve onları controller metodlarına bağlar.
*/
const router = require("express").Router();

module.exports = ({ controller, protect }) => {
  router.get("/", protect, controller.list);
  router.post("/", protect, controller.create);
  router.delete("/:id", protect, controller.deactivate);
  router.patch("/:id", protect, controller.update);
  return router;
};
