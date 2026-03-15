const axios = require("axios");

exports.getWeather = async (req, res) => {
try {

    const { city } = req.query;

    const apiKey = process.env.WEATHER_API_KEY;

    const url = `https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${apiKey}&units=metric`;

    const response = await axios.get(url);

    const data = response.data;

    const temperature = data.main.temp;
    const humidity = data.main.humidity;
    const weather = data.weather[0].description;

    let advice = "";

    if (temperature > 35) {
    advice = "High temperature. Increase irrigation and avoid spraying pesticides during midday.";
    } else if (temperature < 10) {
    advice = "Low temperature. Protect crops from frost.";
    } else if (weather.includes("rain")) {
    advice = "Rain expected. Avoid pesticide spraying.";
    } else {
    advice = "Weather conditions are normal for farming activities.";
    }

    res.json({
    city,
    temperature,
    humidity,
    weather,
    farming_advice: advice
    });

} catch (error) {
    console.error(error);

    res.status(500).json({
    message: "Weather data fetch failed"
    });
    }
};