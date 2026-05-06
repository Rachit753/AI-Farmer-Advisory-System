import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/translation_service.dart';
import '../widgets/glass_container.dart';

class CropRecommendationScreen extends StatefulWidget {
  const CropRecommendationScreen({super.key});

  @override
  State<CropRecommendationScreen> createState() =>
      _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends State<CropRecommendationScreen> {
  final TextEditingController locationController = TextEditingController();

  final TextEditingController soilController = TextEditingController();

  final TextEditingController seasonController = TextEditingController();

  List crops = [];

  bool loading = false;

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

  Future getRecommendation() async {
    setState(() {
      loading = true;
    });

    try {
      var response = await http.post(
        Uri.parse(
          "https://ai-farmer-advisory-backend.onrender.com/api/crop-recommendation",
        ),

        headers: {"Content-Type": "application/json"},

        body: jsonEncode({
          "location": locationController.text,

          "soil_type": soilController.text,

          "season": seasonController.text,

          "language": language,
        }),
      );

      var data = jsonDecode(response.body);

      setState(() {
        crops = data["recommended_crops"] ?? [];

        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  Widget buildField({
    required String hint,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,

      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),

        border: InputBorder.none,
      ),
    );
  }

  Widget cropCard(String crop) {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),

        child: GlassContainer(
          borderRadius: 24,

          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Colors.green,

                  borderRadius: BorderRadius.circular(18),
                ),

                child: const Icon(
                  Icons.agriculture,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Text(
                  crop,

                  style: const TextStyle(
                    color: Colors.white,

                    fontSize: 18,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    locationController.dispose();

    soilController.dispose();

    seasonController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              "assets/images/recommendation.jpg",
              fit: BoxFit.cover,
            ),
          ),

          Container(color: Colors.black.withOpacity(0.65)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),

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
                          TranslationService.getText(language, "crop"),

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
                          buildField(
                            hint: "Location",

                            controller: locationController,
                          ),

                          const SizedBox(height: 20),

                          buildField(
                            hint: "Soil Type",

                            controller: soilController,
                          ),

                          const SizedBox(height: 20),

                          buildField(
                            hint: "Season (Rabi/Kharif)",

                            controller: seasonController,
                          ),

                          const SizedBox(height: 25),

                          SizedBox(
                            width: double.infinity,

                            height: 55,

                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),

                              onPressed: getRecommendation,

                              child: const Text(
                                "Get Recommendation",

                                style: TextStyle(
                                  color: Colors.white,

                                  fontSize: 16,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  if (loading) const CircularProgressIndicator(),

                  if (!loading)
                    Expanded(
                      child: ListView.builder(
                        itemCount: crops.length,

                        itemBuilder: (context, index) {
                          return cropCard(crops[index]);
                        },
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
