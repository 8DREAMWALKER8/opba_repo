const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const morgan = require("morgan");
require("express-async-errors");

const { errorHandler } = require("./middleware/errorHandler");

// legacy routes
const authRoutes = require("./routes/auth.routes");
const meRoutes = require("./routes/me.routes");
const passwordResetRoutes = require("./routes/passwordReset.routes");
const interestRatesRoutes = require("./routes/interestRates.routes");
const loanCalcRoutes = require("./routes/loanCalc.routes");

// auth middleware
const { requireAuth } = require("./middleware/auth");

// --------------------
// CLEAN: Notifications
// --------------------
const NotificationRepositoryMongo = require("./modules/notifications/infrastructure/persistence/repositories/NotificationRepositoryMongo");
const GetMyNotifications = require("./modules/notifications/application/usecases/GetMyNotifications");
const MarkNotificationAsRead = require("./modules/notifications/application/usecases/MarkNotificationAsRead");
const MarkAllAsRead = require("./modules/notifications/application/usecases/MarkAllAsRead");
const makeNotificationsController = require("./modules/notifications/presentation/controller");
const makeNotificationsRoutes = require("./modules/notifications/presentation/routes");

// --------------------
// CLEAN: FX Rates
// --------------------
const SyncTcbmRates = require("./modules/fxrates/application/usecases/SyncTcbmRates");
const AxiosHttpClient = require("./modules/fxrates/infrastructure/services/AxiosHttpClient");
const TcmbXmlParser = require("./modules/fxrates/infrastructure/services/TcmbXmlParser");
const FxRateRepositoryMongo = require("./modules/fxrates/infrastructure/persistence/repositories/FxRateRepositoryMongo");
const makeFxRatesController = require("./modules/fxrates/presentation/controller");
const makeFxRatesRoutes = require("./modules/fxrates/presentation/routes");

// --------------------
// CLEAN: Accounts
// --------------------
const BankAccountRepositoryMongo = require("./modules/accounts/infrastructure/persistence/repositories/BankAccountRepositoryMongo");
const ListAccounts = require("./modules/accounts/application/usecases/ListAccounts");
const CreateAccount = require("./modules/accounts/application/usecases/CreateAccount");
const DeactivateAccount = require("./modules/accounts/application/usecases/DeactivateAccount");
const makeAccountsController = require("./modules/accounts/presentation/controller");
const makeAccountsRoutes = require("./modules/accounts/presentation/routes");

// --------------------
// CLEAN: Budgets
// --------------------
const budgetsRouter = require("./modules/budgets/presentation/routes");

// --------------------
// CLEAN: Transactions
// --------------------
const transactionsRouter = require("./modules/transactions/presentation/routes");

const app = express();

// --------------------
// Clean Accounts wiring
// --------------------
const accountRepo = new BankAccountRepositoryMongo();
const listAccounts = new ListAccounts({ repo: accountRepo });
const createAccount = new CreateAccount({ repo: accountRepo });
const deactivateAccount = new DeactivateAccount({ repo: accountRepo });

const accountsController = makeAccountsController({
  listAccounts,
  createAccount,
  deactivateAccount,
});

const accountsRouter = makeAccountsRoutes({
  controller: accountsController,
  protect: requireAuth,
});

// --------------------
// Clean Notifications wiring
// --------------------
const notificationRepo = new NotificationRepositoryMongo();

const getMyNotifications = new GetMyNotifications({ notificationRepo });
const markNotificationAsRead = new MarkNotificationAsRead({ notificationRepo });
const markAllAsRead = new MarkAllAsRead({ notificationRepo });

const notificationsController = makeNotificationsController({
  getMyNotifications,
  markNotificationAsRead,
  markAllAsRead,
});

const notificationsRouter = makeNotificationsRoutes({
  controller: notificationsController,
  protect: requireAuth,
});

// --------------------
// Clean FX wiring
// --------------------
const fxRateRepo = new FxRateRepositoryMongo();

const syncTcbmRates = new SyncTcbmRates({
  httpClient: new AxiosHttpClient(),
  xmlParser: new TcmbXmlParser(),
  fxRateRepo,
  tcmbUrl: process.env.TCMB_URL,
});

const fxController = makeFxRatesController({ syncTcbmRates, fxRateRepo });
const fxRoutes = makeFxRatesRoutes(fxController);

// --------------------
// Middlewares
// --------------------
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(morgan("dev"));

// --------------------
// Routes
// --------------------
app.use("/auth", authRoutes);
app.use("/me", meRoutes);

// clean
app.use("/accounts", accountsRouter);
app.use("/transactions", transactionsRouter);
app.use("/budgets", budgetsRouter);

app.use("/auth", passwordResetRoutes);
app.use("/notifications", notificationsRouter);
app.use("/api/fx", fxRoutes);

app.use("/api/interest-rates", interestRatesRoutes);
app.use("/api/loan", loanCalcRoutes);

// health
app.get("/health", (req, res) => {
  res.json({
    ok: true,
    service: "opba-backend",
    time: new Date().toISOString(),
  });
});

// error handler
app.use(errorHandler);

module.exports = { app };
