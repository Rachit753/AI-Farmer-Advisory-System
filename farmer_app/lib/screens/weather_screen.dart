import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Map weatherData = {};
  bool loading = false;

  final TextEditingController cityController = TextEditingController();

  Future fetchWeather(String city) async {
    setState(() {
      loading = true;
    });

    var response = await http.get(
      Uri.parse("http://localhost:5000/api/weather?city=$city"),
    );

    var data = jsonDecode(response.body);

    setState(() {
      weatherData = data;
      loading = false;
    });

    checkWeatherAlert(data);
  }

  void checkWeatherAlert(Map data) {
    String weather = data["weather"].toLowerCase();
    double temp = data["temperature"];

    if (weather.contains("rain") ||
        weather.contains("storm") ||
        weather.contains("wind") ||
        temp > 40 ||
        temp < 5) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Weather Alert ⚠️"),
          content: Text(
            "Weather condition today: ${data["weather"]}\n\n${data["farming_advice"]}",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather Advisory"),
        backgroundColor: Colors.green,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: "Enter City",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                fetchWeather(cityController.text);
              },
              child: const Text("Check Weather"),
            ),

            const SizedBox(height: 20),

            loading
                ? const CircularProgressIndicator()
                : weatherData.isEmpty
                ? const Text("Enter a city to see weather")
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "City: ${weatherData["city"]}",
                        style: const TextStyle(fontSize: 20),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Temperature: ${weatherData["temperature"]} °C",
                        style: const TextStyle(fontSize: 18),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Humidity: ${weatherData["humidity"]} %",
                        style: const TextStyle(fontSize: 18),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Weather: ${weatherData["weather"]}",
                        style: const TextStyle(fontSize: 18),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Farming Advice",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        weatherData["farming_advice"],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
