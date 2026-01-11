// Döviz kuru güncelleme işlemini cron ile periyodik olarak tetikler.

const cron = require("node-cron");

function startFxCron(syncTcbmRates) {
  console.log("FX CRON BAŞLADI");

  syncTcbmRates.execute().catch((e) => console.error("FX init çöktü:", e.message));

  cron.schedule("5 9 * * *", () => {
    console.log("FX CRON TETİKLENDİ");
    syncTcbmRates.execute().catch((e) => console.error("FX cron çöktü:", e.message));
  });
}

module.exports = { startFxCron };
