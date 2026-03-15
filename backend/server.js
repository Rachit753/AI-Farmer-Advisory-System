const express = require("express");
const cors = require("cors");
require("dotenv").config();

const connectDB = require("./config/db");
const aiRoutes = require("./routes/aiRoutes");

const app = express();

connectDB();

app.use(cors());
app.use(express.json());

app.use("/api", aiRoutes);

app.get("/", (req, res) => {
  res.send("AI Farmer Advisory Backend Running");
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});