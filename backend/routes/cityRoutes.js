const express = require("express");
const router = express.Router();

const axios = require("axios");

router.get(
  "/city-search",
  async (req, res) => {
    try {
      const query = req.query.q;

      if (!query) {
        return res.json([]);
      }

      const apiKey =
        process.env.WEATHER_API_KEY;

      const url =
        `https://api.openweathermap.org/geo/1.0/direct?q=${query},IN&limit=10&appid=${apiKey}`;

      const response =
        await axios.get(url);

      const uniqueCities = [];

      const seen = new Set();

      response.data.forEach((item) => {
        const cityName =
          `${item.name}, ${item.state ?? ""}, ${item.country}`;

        if (!seen.has(cityName)) {
          seen.add(cityName);

          uniqueCities.push({
            name: item.name,
            state:
              item.state || "",
            country:
              item.country,
          });
        }
      });

      res.json(uniqueCities);
    } catch (error) {
      console.error(error);

      res.status(500).json([]);
    }
  },
);

module.exports = router;