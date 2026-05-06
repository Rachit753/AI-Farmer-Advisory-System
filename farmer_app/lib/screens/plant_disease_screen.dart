import 'dart:convert';
import 'dart:typed_data';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../widgets/glass_container.dart';

class PlantDiseaseScreen extends StatefulWidget {
  const PlantDiseaseScreen({super.key});

  @override
  State<PlantDiseaseScreen> createState() => _PlantDiseaseScreenState();
}

class _PlantDiseaseScreenState extends State<PlantDiseaseScreen> {
  Uint8List? imageBytes;

  XFile? imageFile;

  String diagnosis = "";

  bool loading = false;

  final picker = ImagePicker();

  Future pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      imageBytes = await picked.readAsBytes();

      setState(() {
        imageFile = picked;
      });
    }
  }

  Future analyzePlant() async {
    if (imageFile == null) return;

    setState(() {
      loading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',

        Uri.parse(
          "https://ai-farmer-advisory-backend.onrender.com/api/analyze-plant",
        ),
      );

      request.files.add(
        await http.MultipartFile.fromBytes(
          'image',
          imageBytes!,
          filename: "leaf.jpg",
        ),
      );

      var response = await request.send();

      var responseData = await response.stream.bytesToString();

      var data = jsonDecode(responseData);

      setState(() {
        diagnosis = data["diagnosis"];

        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset("assets/images/disease.jpg", fit: BoxFit.cover),
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

                        const Text(
                          "Plant Disease",

                          style: TextStyle(
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
                          imageBytes != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),

                                  child: Image.memory(
                                    imageBytes!,

                                    height: 240,

                                    width: double.infinity,

                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  height: 240,

                                  width: double.infinity,

                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),

                                    color: Colors.white.withOpacity(0.08),
                                  ),

                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,

                                    children: [
                                      Icon(
                                        Icons.image_outlined,

                                        color: Colors.white.withOpacity(0.7),

                                        size: 70,
                                      ),

                                      const SizedBox(height: 15),

                                      const Text(
                                        "No image selected",

                                        style: TextStyle(
                                          color: Colors.white,

                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                          const SizedBox(height: 25),

                          SizedBox(
                            width: double.infinity,

                            height: 55,

                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),

                              onPressed: pickImage,

                              icon: const Icon(
                                Icons.photo,

                                color: Colors.white,
                              ),

                              label: const Text(
                                "Select Leaf Image",

                                style: TextStyle(
                                  color: Colors.white,

                                  fontSize: 16,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          SizedBox(
                            width: double.infinity,

                            height: 55,

                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),

                              onPressed: analyzePlant,

                              icon: const Icon(
                                Icons.science_outlined,

                                color: Colors.white,
                              ),

                              label: const Text(
                                "Analyze Plant",

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

                  if (!loading && diagnosis.isNotEmpty)
                    Expanded(
                      child: FadeInUp(
                        child: SingleChildScrollView(
                          child: GlassContainer(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.medical_services,

                                      color: Colors.white,
                                    ),

                                    SizedBox(width: 10),

                                    Text(
                                      "Diagnosis Result",

                                      style: TextStyle(
                                        color: Colors.white,

                                        fontSize: 22,

                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                Text(
                                  diagnosis,

                                  style: const TextStyle(
                                    color: Colors.white,

                                    fontSize: 16,

                                    height: 1.7,
                                  ),
                                ),
                              ],
                            ),
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
