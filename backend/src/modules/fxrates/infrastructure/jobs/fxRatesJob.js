const cron = require("node-cron");

function startFxCron(syncTcbmRates) {
  console.log("FX CRON STARTED");

  // server açılınca 1 kere
  syncTcbmRates.execute().catch((e) => console.error("FX init failed:", e.message));

  // her gün 09:05
  cron.schedule("5 9 * * *", () => {
    console.log("FX CRON TRIGGERED");
    syncTcbmRates.execute().catch((e) => console.error("FX cron failed:", e.message));
  });
}

module.exports = { startFxCron };
