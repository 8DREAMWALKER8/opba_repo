const axios = require("axios");

class AxiosHttpClient {
  async get(url) {
    const res = await axios.get(url, { timeout: 10000 });
    return res.data;
  }
}

module.exports = AxiosHttpClient;
