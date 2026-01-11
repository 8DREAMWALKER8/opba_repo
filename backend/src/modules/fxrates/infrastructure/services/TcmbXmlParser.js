// TCMB’den gelen XML formatındaki döviz kuru verisini okuyup
// USD, EUR ve GBP kurlarını ayıklayarak kullanılabilir hale getirir.

class TcmbXmlParser {
  parse(xml) {
    const usdBlock = xml.match(/<Currency[^>]*CurrencyCode="USD"[\s\S]*?<\/Currency>/);
    const eurBlock = xml.match(/<Currency[^>]*CurrencyCode="EUR"[\s\S]*?<\/Currency>/);
    const gbpBlock = xml.match(/<Currency[^>]*CurrencyCode="GBP"[\s\S]*?<\/Currency>/);

    if (!usdBlock || !eurBlock || !gbpBlock) throw new Error("TCMB XML içinde USD/EUR/GBP bulunamadı");

    const getRate = (block) => {
      const selling = block[0].match(/<ForexSelling>(.*?)<\/ForexSelling>/)?.[1];
      const buying = block[0].match(/<ForexBuying>(.*?)<\/ForexBuying>/)?.[1];
      const val = (selling || buying || "").trim().replace(",", ".");
      const num = Number(val);
      if (!Number.isFinite(num) || num <= 0) throw new Error("Kur parse edilemedi");
      return num;
    };

    return { USD: getRate(usdBlock), EUR: getRate(eurBlock), GBP: getRate(gbpBlock), TRY: 1 };
  }
}

module.exports = TcmbXmlParser;
