require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const authRoutes = require("./routes/authRoutes");
const userRoutes = require("./routes/userRoutes");
const notificationRoutes = require("./routes/notificationRoutes");


const app = express();

app.use(cors());
app.use(express.json());

// Rotalar
app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/notifications", notificationRoutes);


// DEBUG: çalıştığımız sunucuyu anlamak için
app.get("/", (req, res) => {
  res.send("OPBA API ÇALIŞIYOR - DEBUG PORT");
});

// MongoDB Bağlantısı
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => {
    console.log("MongoDB bağlantısı başarılı!");

    // PORT’u ŞİMDİLİK 5002 yapalım ki kesin bu server’a gidelim
    const PORT = 5002;

    app.listen(PORT, () => {
      console.log(`Server ${PORT} portunda çalışıyor`);
    });
  })
  .catch((err) => {
    console.error("MongoDB bağlantı hatası:", err);
  });

module.exports = app;
