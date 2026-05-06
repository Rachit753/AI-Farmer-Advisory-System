const axios = require("axios");
const Groq = require("groq-sdk");

const groq = new Groq({
  apiKey: process.env.GROQ_API_KEY,
});

exports.getWeather = async (req, res) => {
  try {
    const { city, language } = req.query;

    if (!city) {
      return res.status(400).json({
        success: false,
        message: "City is required",
      });
    }

    const apiKey =
      process.env.WEATHER_API_KEY;

    const url =
      `https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${apiKey}&units=metric`;

    const response = await axios.get(url);

    const data = response.data;

    const temperature =
      data.main.temp;

    const humidity =
      data.main.humidity;

    const weather =
      data.weather[0].description;

    let advice = "";

    if (temperature > 35) {
      advice =
        "High temperature. Increase irrigation and avoid spraying pesticides during midday.";
    } else if (temperature < 10) {
      advice =
        "Low temperature. Protect crops from frost.";
    } else if (
      weather.includes("rain")
    ) {
      advice =
        "Rain expected. Avoid pesticide spraying.";
    } else {
      advice =
        "Weather conditions are normal for farming activities.";
    }

    let translatedAdvice = advice;

    if (
      language &&
      language !== "English"
    ) {
      const completion =
        await groq.chat.completions.create({
          model:
            "llama-3.1-8b-instant",

          messages: [
            {
              role: "system",
              content: `
Translate the following farming advice into ${language}.

IMPORTANT:
1. Use native script.
2. Keep meaning same.
3. Return ONLY translated text.
`,
            },

            {
              role: "user",
              content: advice,
            },
          ],
        });

      translatedAdvice =
        completion.choices?.[0]?.message
          ?.content || advice;
    }

    res.json({
      success: true,
      city,
      temperature,
      humidity,
      weather,
      farming_advice:
        translatedAdvice,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message:
        "Weather data fetch failed",
    });
  }
};