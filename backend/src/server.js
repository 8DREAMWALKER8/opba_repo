require("dotenv").config();
const { app } = require("./app");
const { connectDB } = require("./config/db");

const PORT = process.env.PORT || 8080;

async function start() {
  await connectDB();
  const { startFxCron } = require("./jobs/fxRatesJob");
startFxCron();

  app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
}

start();
