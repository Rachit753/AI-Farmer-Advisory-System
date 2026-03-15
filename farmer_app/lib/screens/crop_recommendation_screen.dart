import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Future getRecommendation() async {
    setState(() {
      loading = true;
    });

    var response = await http.post(
      Uri.parse("http://localhost:5000/api/crop-recommendation"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "location": locationController.text,
        "soil_type": soilController.text,
        "season": seasonController.text,
      }),
    );

    var data = jsonDecode(response.body);

    setState(() {
      crops = data["recommended_crops"];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crop Recommendation"),
        backgroundColor: Colors.green,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: "Location",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: soilController,
              decoration: const InputDecoration(
                labelText: "Soil Type",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: seasonController,
              decoration: const InputDecoration(
                labelText: "Season (Rabi/Kharif)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: getRecommendation,
              child: const Text("Get Recommendation"),
            ),

            const SizedBox(height: 20),

            loading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: crops.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.agriculture),
                            title: Text(crops[index]),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
