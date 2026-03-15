import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class PlantDiseaseScreen extends StatefulWidget {
  const PlantDiseaseScreen({super.key});

  @override
  State<PlantDiseaseScreen> createState() => _PlantDiseaseScreenState();
}

class _PlantDiseaseScreenState extends State<PlantDiseaseScreen> {
  Uint8List? imageBytes;
  XFile? imageFile;

  String diagnosis = "";

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

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("http://localhost:5000/api/analyze-plant"),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plant Disease Detection"),
        backgroundColor: Colors.green,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            imageBytes != null
                ? Image.memory(imageBytes!, height: 200)
                : const Text("No image selected"),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Select Leaf Image"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: analyzePlant,
              child: const Text("Analyze Plant"),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: Text(diagnosis, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
