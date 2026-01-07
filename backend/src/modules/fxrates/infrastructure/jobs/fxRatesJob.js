const cron = require("node-cron");

function startFxCron(syncTcbmRates) {
  console.log("FX CRON BAŞLADI");

  // server açılınca 1 kere
  syncTcbmRates.execute().catch((e) => console.error("FX init çöktü:", e.message));

  // her gün 09:05
  cron.schedule("5 9 * * *", () => {
    console.log("FX CRON TETİKLENDİ");
    syncTcbmRates.execute().catch((e) => console.error("FX cron çöktü:", e.message));
  });
}

module.exports = { startFxCron };
