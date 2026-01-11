class SyncTcbmRates {
  constructor({ httpClient, xmlParser, fxRateRepo, tcmbUrl }) {
    this.httpClient = httpClient;
    this.xmlParser = xmlParser;
    this.fxRateRepo = fxRateRepo;
    this.tcmbUrl = tcmbUrl;
  }

  dayStartUTC() {
    const d = new Date();
    const yyyy = d.getFullYear();
    const mm = String(d.getMonth() + 1).padStart(2, "0");
    const dd = String(d.getDate()).padStart(2, "0");
    return new Date(`${yyyy}-${mm}-${dd}T00:00:00.000Z`);
  }

  async execute() {
    if (!this.tcmbUrl) throw new Error("TCMB_URL missing");
    const xml = await this.httpClient.get(this.tcmbUrl);
    const rates = this.xmlParser.parse(xml);
    const date = this.dayStartUTC();
    await this.fxRateRepo.upsertMany(rates, date);

    return { date, rates };
  }
}

module.exports = SyncTcbmRates;
