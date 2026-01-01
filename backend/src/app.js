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

// fxrates wiring (API için)
const SyncTcbmRates = require("./modules/fxrates/application/usecases/SyncTcbmRates");
const AxiosHttpClient = require("./modules/fxrates/infrastructure/services/AxiosHttpClient");
const TcmbXmlParser = require("./modules/fxrates/infrastructure/services/TcmbXmlParser");
const FxRateRepositoryMongo = require("./modules/fxrates/infrastructure/persistence/repositories/FxRateRepositoryMongo");
const makeFxRatesController = require("./modules/fxrates/presentation/controller");
const makeFxRatesRoutes = require("./modules/fxrates/presentation/routes");


const app = express();

const fxRateRepo = new FxRateRepositoryMongo();
const syncTcbmRates = new SyncTcbmRates({
  httpClient: new AxiosHttpClient(),
  xmlParser: new TcmbXmlParser(),
  fxRateRepo,
  tcmbUrl: process.env.TCMB_URL,
});

const fxController = makeFxRatesController({ syncTcbmRates, fxRateRepo });
const fxRoutes = makeFxRatesRoutes(fxController);


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
app.use("/api/fx", fxRoutes);
app.use("/api/interest-rates", interestRatesRoutes);
app.use("/api/loan", loanCalcRoutes);

app.get("/health", (req, res) => {
  res.json({ ok: true, service: "opba-backend", time: new Date().toISOString() });
});

app.use(errorHandler);

module.exports = { app };
