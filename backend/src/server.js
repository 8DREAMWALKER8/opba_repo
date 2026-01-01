require("dotenv").config();
const { app } = require("./app");
const { connectDB } = require("./config/db");

const SyncTcbmRates = require("./modules/fxrates/application/usecases/SyncTcbmRates");
const AxiosHttpClient = require("./modules/fxrates/infrastructure/services/AxiosHttpClient");
const TcmbXmlParser = require("./modules/fxrates/infrastructure/services/TcmbXmlParser");
const FxRateRepositoryMongo = require("./modules/fxrates/infrastructure/persistence/repositories/FxRateRepositoryMongo");
const { startFxCron } = require("./modules/fxrates/infrastructure/jobs/fxRatesJob");

const PORT = process.env.PORT || 8080;

async function start() {
  await connectDB();

  const syncTcbmRates = new SyncTcbmRates({
    httpClient: new AxiosHttpClient(),
    xmlParser: new TcmbXmlParser(),
    fxRateRepo: new FxRateRepositoryMongo(),
    tcmbUrl: process.env.TCMB_URL,
  });

  startFxCron(syncTcbmRates);

  app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
}

start();
