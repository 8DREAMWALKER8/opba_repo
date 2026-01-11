// Döviz kuru verileri için repository arayüzü.

class FxRateRepository {
  async upsertMany() {
    throw new Error("NOT_IMPLEMENTED");
  }
  async getLatest() {
    throw new Error("NOT_IMPLEMENTED");
  }
}
module.exports = FxRateRepository;
