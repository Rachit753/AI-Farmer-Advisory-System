const express = require("express");
const cors = require("cors");
require("dotenv").config();

const connectDB = require("./config/db");

const aiRoutes = require("./routes/aiRoutes");
const plantRoutes = require("./routes/plantRoutes");
const weatherRoutes = require("./routes/weatherRoutes");
const cropRoutes = require("./routes/cropRoutes");
const historyRoutes = require("./routes/historyRoutes");
const farmerRoutes = require("./routes/farmerRoutes");

const app = express();

connectDB();

app.use(cors());
app.use(express.json());

app.use("/api", aiRoutes);
app.use("/api", plantRoutes);
app.use("/api", weatherRoutes);
app.use("/api", cropRoutes);
app.use("/api", historyRoutes);
app.use("/api", farmerRoutes);

app.get("/", (req, res) => {
  res.send("AI Farmer Advisory Backend Running");
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});