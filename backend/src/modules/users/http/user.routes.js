const router = require("express").Router();
const { requireAuth } = require("../../../middleware/auth");

module.exports = ({ controller }) => {
  router.post("/register", controller.register);
  router.post("/login/step1", controller.loginStep1Handler);
  router.post("/login/step2", controller.loginStep2Handler);

  router.patch("/me/update", requireAuth, controller.updateMe);

  router.get("/security-questions", controller.getSecurityQuestions);
  router.get("/me", requireAuth, controller.me);

  return router;
};
