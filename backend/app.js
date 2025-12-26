const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const morgan = require("morgan");
require("express-async-errors");

const { errorHandler } = require("./middleware/errorHandler");
const authRoutes = require("./routes/auth.routes");
const meRoutes = require("./routes/me.routes");
const accountsRoutes = require("./routes/accounts.routes");
const transactionsRoutes = require("./routes/transactions.routes");
const budgetsRoutes = require("./routes/budgets.routes");
const passwordResetRoutes = require("./routes/passwordReset.routes");
const notificationsRoutes = require("./routes/notifications.routes");
const fxRateRoutes = require("./routes/fxRateRoutes");
const interestRatesRoutes = require("./routes/interestRates.routes");
const loanCalcRoutes = require("./routes/loanCalc.routes");

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(morgan("dev"));

app.use("/auth", authRoutes);
app.use("/me", meRoutes);
app.use("/accounts", accountsRoutes);
app.use("/transactions", transactionsRoutes);
app.use("/budgets", budgetsRoutes);
app.use("/auth", passwordResetRoutes);
app.use("/notifications", notificationsRoutes);
app.use("/api/fx", fxRateRoutes);
app.use("/api/interest-rates", interestRatesRoutes);
app.use("/api/loan", loanCalcRoutes);

app.get("/health", (req, res) => {
  res.json({ ok: true, service: "opba-backend", time: new Date().toISOString() });
});

app.use(errorHandler);

module.exports = { app };
