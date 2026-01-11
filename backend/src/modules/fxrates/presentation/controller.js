// Döviz kurlarıyla ilgili API isteklerini karşılar.
// Güncel kur listesini getirir veya TCMB’den kurları manuel olarak günceller.

module.exports = ({ syncTcbmRates, fxRateRepo }) => ({
  getLatest: async (req, res) => {
    const latest = await fxRateRepo.getLatest(50);
    res.json({ ok: true, latest });
  },

  syncNow: async (req, res) => {
    const out = await syncTcbmRates.execute();
    res.json({ ok: true, ...out });
  },
});
