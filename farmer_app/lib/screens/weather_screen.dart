import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/translation_service.dart';
import '../widgets/glass_container.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Map weatherData = {};

  bool loading = false;

  final TextEditingController cityController = TextEditingController();

  String language = "English";

  @override
  void initState() {
    super.initState();

    loadLanguage();
  }

  Future loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      language = prefs.getString("language") ?? "English";
    });
  }

  Future<List<String>> searchCities(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse(
          "https://ai-farmer-advisory-backend.onrender.com/api/city-search?q=$query",
        ),
      );

      if (response.statusCode != 200) {
        return [];
      }

      final List data = jsonDecode(response.body);

      return data.map<String>((item) {
        return "${item["name"]}, ${item["state"]}, ${item["country"]}";
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future fetchWeather(String city) async {
    if (city.trim().isEmpty) return;

    String finalCity = city.split(",")[0];

    setState(() {
      loading = true;
    });

    try {
      var response = await http.get(
        Uri.parse(
          "https://ai-farmer-advisory-backend.onrender.com/api/weather?city=${Uri.encodeComponent(finalCity)}&language=$language",
        ),
      );

      var data = jsonDecode(response.body);

      setState(() {
        weatherData = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  Widget weatherInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: GlassContainer(
        borderRadius: 22,

        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),

            const SizedBox(height: 12),

            Text(
              title,

              style: TextStyle(
                color: Colors.white.withOpacity(0.8),

                fontSize: 14,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              value,

              style: const TextStyle(
                color: Colors.white,

                fontSize: 18,

                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset("assets/images/weather.jpg", fit: BoxFit.cover),
          ),

          Container(color: Colors.black.withOpacity(0.6)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),

              child: Column(
                children: [
                  FadeInDown(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },

                          child: GlassContainer(
                            borderRadius: 18,

                            padding: const EdgeInsets.all(10),

                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(width: 18),

                        Text(
                          TranslationService.getText(language, "weather"),

                          style: const TextStyle(
                            color: Colors.white,

                            fontSize: 28,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  FadeInDown(
                    delay: const Duration(milliseconds: 200),

                    child: GlassContainer(
                      child: Column(
                        children: [
                          TypeAheadField<String>(
                            suggestionsCallback: (pattern) async {
                              return await searchCities(pattern);
                            },

                            itemBuilder: (context, suggestion) {
                              return ListTile(
                                title: Text(
                                  suggestion,

                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            },

                            onSelected: (suggestion) {
                              cityController.text = suggestion;
                            },

                            builder: (context, controller, focusNode) {
                              controller.text = cityController.text;

                              return TextField(
                                controller: controller,

                                focusNode: focusNode,

                                style: const TextStyle(color: Colors.white),

                                decoration: InputDecoration(
                                  hintText: TranslationService.getText(
                                    language,
                                    "enter_city",
                                  ),

                                  border: InputBorder.none,
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,

                            height: 55,

                            child: ElevatedButton(
                              onPressed: () {
                                fetchWeather(cityController.text);
                              },

                              child: Text(
                                TranslationService.getText(
                                  language,
                                  "check_weather",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  if (loading) const CircularProgressIndicator(),

                  if (weatherData.isNotEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        child: FadeInUp(
                          child: Column(
                            children: [
                              GlassContainer(
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.cloud,
                                      size: 80,
                                      color: Colors.white,
                                    ),

                                    const SizedBox(height: 10),

                                    Text(
                                      weatherData["city"],

                                      style: const TextStyle(
                                        color: Colors.white,

                                        fontSize: 30,

                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    Text(
                                      "${weatherData["temperature"]}°C",

                                      style: const TextStyle(
                                        color: Colors.white,

                                        fontSize: 55,

                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    Text(
                                      weatherData["weather"],

                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),

                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              Row(
                                children: [
                                  weatherInfoCard(
                                    title: TranslationService.getText(
                                      language,
                                      "humidity",
                                    ),

                                    value: "${weatherData["humidity"]}%",

                                    icon: Icons.water_drop,
                                  ),

                                  const SizedBox(width: 15),

                                  weatherInfoCard(
                                    title: TranslationService.getText(
                                      language,
                                      "temperature",
                                    ),

                                    value: "${weatherData["temperature"]}°C",

                                    icon: Icons.thermostat,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              GlassContainer(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      TranslationService.getText(
                                        language,
                                        "farming_advice",
                                      ),

                                      style: const TextStyle(
                                        color: Colors.white,

                                        fontSize: 22,

                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 15),

                                    Text(
                                      weatherData["farming_advice"],

                                      style: const TextStyle(
                                        color: Colors.white,

                                        fontSize: 16,

                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
