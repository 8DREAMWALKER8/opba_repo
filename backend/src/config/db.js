const mongoose = require("mongoose");

async function connectDB() {
  const uri = process.env.MONGO_URI;

  if (!uri) {
    console.warn("MONGODB_URI yok. DB bağlantısı atlanıyor.");
    return;
  }

  mongoose.set("strictQuery", true);
  await mongoose.connect(uri);
  console.log(" MongoDB connected");
}

module.exports = { connectDB };
