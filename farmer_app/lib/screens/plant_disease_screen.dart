import 'dart:convert';
import 'dart:typed_data';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/glass_container.dart';

class PlantDiseaseScreen extends StatefulWidget {
  const PlantDiseaseScreen({super.key});

  @override
  State<PlantDiseaseScreen> createState() => _PlantDiseaseScreenState();
}

class _PlantDiseaseScreenState extends State<PlantDiseaseScreen> {
  Uint8List? imageBytes;

  XFile? imageFile;

  Map diagnosis = {};

  bool loading = false;

  String language = "English";

  final picker = ImagePicker();

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

  Future pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      imageBytes = await picked.readAsBytes();

      setState(() {
        imageFile = picked;

        diagnosis = {};
      });
    }
  }

  Future analyzePlant() async {
    if (imageFile == null) return;

    setState(() {
      loading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String selectedLanguage = prefs.getString("language") ?? "English";

      var request = http.MultipartRequest(
        'POST',

        Uri.parse(
          "https://ai-farmer-advisory-backend.onrender.com/api/analyze-plant",
        ),
      );

      request.fields["language"] = selectedLanguage;

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
        diagnosis = data["diagnosis"] ?? {};

        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to analyze plant")));
    }
  }

  Widget buildResultRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style: const TextStyle(
              color: Colors.greenAccent,

              fontSize: 18,

              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            value,

            style: const TextStyle(
              color: Colors.white,

              fontSize: 16,

              height: 1.7,
            ),
          ),
        ],
      ),
    );
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

                        Text(
                          language == "Hindi"
                              ? "पौधा रोग"
                              : language == "Punjabi"
                              ? "ਪੌਦੇ ਦੀ ਬਿਮਾਰੀ"
                              : language == "Telugu"
                              ? "మొక్క వ్యాధి"
                              : language == "Malayalam"
                              ? "സസ്യ രോഗം"
                              : "Plant Disease",

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

                                      Text(
                                        language == "Hindi"
                                            ? "कोई तस्वीर चयनित नहीं"
                                            : language == "Punjabi"
                                            ? "ਕੋਈ ਤਸਵੀਰ ਨਹੀਂ ਚੁਣੀ"
                                            : language == "Telugu"
                                            ? "చిత్రం ఎంపిక చేయలేదు"
                                            : language == "Malayalam"
                                            ? "ചിത്രം തിരഞ്ഞെടുത്തിട്ടില്ല"
                                            : "No image selected",

                                        style: const TextStyle(
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

                              label: Text(
                                language == "Hindi"
                                    ? "पत्ती की तस्वीर चुनें"
                                    : language == "Punjabi"
                                    ? "ਪੱਤੇ ਦੀ ਤਸਵੀਰ ਚੁਣੋ"
                                    : language == "Telugu"
                                    ? "ఆకు చిత్రాన్ని ఎంచుకోండి"
                                    : language == "Malayalam"
                                    ? "ഇലയുടെ ചിത്രം തിരഞ്ഞെടുക്കുക"
                                    : "Select Leaf Image",

                                style: const TextStyle(
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

                              label: Text(
                                language == "Hindi"
                                    ? "पौधे का विश्लेषण करें"
                                    : language == "Punjabi"
                                    ? "ਪੌਦੇ ਦਾ ਵਿਸ਼ਲੇਸ਼ਣ ਕਰੋ"
                                    : language == "Telugu"
                                    ? "మొక్కను విశ్లేషించండి"
                                    : language == "Malayalam"
                                    ? "സസ്യം വിശകലനം ചെയ്യുക"
                                    : "Analyze Plant",

                                style: const TextStyle(
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
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.medical_services,

                                      color: Colors.white,
                                    ),

                                    const SizedBox(width: 10),

                                    Text(
                                      language == "Hindi"
                                          ? "विश्लेषण परिणाम"
                                          : language == "Punjabi"
                                          ? "ਵਿਸ਼ਲੇਸ਼ਣ ਨਤੀਜਾ"
                                          : language == "Telugu"
                                          ? "విశ్లేషణ ఫలితం"
                                          : language == "Malayalam"
                                          ? "വിശകലന ഫലം"
                                          : "Diagnosis Result",

                                      style: const TextStyle(
                                        color: Colors.white,

                                        fontSize: 22,

                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 25),

                                buildResultRow(
                                  language == "Hindi"
                                      ? "रोग"
                                      : language == "Punjabi"
                                      ? "ਬਿਮਾਰੀ"
                                      : language == "Telugu"
                                      ? "వ్యాధి"
                                      : language == "Malayalam"
                                      ? "രോഗം"
                                      : "Disease",

                                  diagnosis["disease"] ?? "",
                                ),

                                buildResultRow(
                                  language == "Hindi"
                                      ? "कारण"
                                      : language == "Punjabi"
                                      ? "ਕਾਰਣ"
                                      : language == "Telugu"
                                      ? "కారణం"
                                      : language == "Malayalam"
                                      ? "കാരണം"
                                      : "Cause",

                                  diagnosis["cause"] ?? "",
                                ),

                                buildResultRow(
                                  language == "Hindi"
                                      ? "उपचार"
                                      : language == "Punjabi"
                                      ? "ਇਲਾਜ"
                                      : language == "Telugu"
                                      ? "చికిత్స"
                                      : language == "Malayalam"
                                      ? "ചികിത്സ"
                                      : "Treatment",

                                  diagnosis["treatment"] ?? "",
                                ),

                                buildResultRow(
                                  language == "Hindi"
                                      ? "रोकथाम"
                                      : language == "Punjabi"
                                      ? "ਰੋਕਥਾਮ"
                                      : language == "Telugu"
                                      ? "నివారణ"
                                      : language == "Malayalam"
                                      ? "പ്രതിരോധം"
                                      : "Prevention",

                                  diagnosis["prevention"] ?? "",
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
