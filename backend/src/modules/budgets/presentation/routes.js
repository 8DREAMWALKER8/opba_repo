const express = require("express");
const router = express.Router();

const { requireAuth } = require("../../../middleware/auth");
const { getBudgets, setBudgetLimit } = require("./controller");

router.get("/", requireAuth, getBudgets);
router.post("/", requireAuth, setBudgetLimit);

console.log("handlers:", typeof getBudgets, typeof setBudgetLimit);

module.exports = router;
