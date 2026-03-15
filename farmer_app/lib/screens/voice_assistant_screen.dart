import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  final SpeechToText speech = SpeechToText();
  final FlutterTts tts = FlutterTts();

  bool isListening = false;

  String userSpeech = "";
  String aiResponse = "";

  Future startListening() async {
    bool available = await speech.initialize();

    if (available) {
      setState(() {
        isListening = true;
      });

      speech.listen(
        onResult: (result) {
          setState(() {
            userSpeech = result.recognizedWords;
          });

          if (result.finalResult) {
            stopListening();

            askAI(userSpeech);
          }
        },
      );
    }
  }

  void stopListening() {
    speech.stop();

    setState(() {
      isListening = false;
    });
  }

  Future askAI(String question) async {
    var response = await http.post(
      Uri.parse("http://localhost:5000/api/ask-ai"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "farmer_id": "69b67016036ad4d9da8b0537",
        "question": question,
      }),
    );

    print(response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var result = data["result"];

      String formattedResponse =
          """
Problem: ${result["problem"]}

Possible Causes:
${result["possible_causes"].join(", ")}

Treatment:
${result["treatment"]}

Fertilizer:
${result["fertilizer"]}

Pesticide:
${result["pesticide"]}

Prevention:
${result["prevention"]}
""";

      setState(() {
        aiResponse = formattedResponse;
      });

      speak(formattedResponse);
    } else {
      setState(() {
        aiResponse = "Error connecting to AI service.";
      });
    }
  }

  Future speak(String text) async {
    String language = "en-US";

    if (text.contains(RegExp(r'[ऀ-ॿ]'))) {
      language = "hi-IN"; // Hindi
    } else if (text.contains(RegExp(r'[ਅ-੿]'))) {
      language = "pa-IN"; // Punjabi
    } else if (text.contains(RegExp(r'[ఀ-౿]'))) {
      language = "te-IN"; // Telugu
    } else if (text.contains(RegExp(r'[ഀ-ൿ]'))) {
      language = "ml-IN"; // Malayalam
    }

    await tts.setLanguage(language);
    await tts.setSpeechRate(0.45);
    await tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voice Assistant"),
        backgroundColor: Colors.green,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Tap the microphone and ask your farming question",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 30),

            IconButton(
              icon: Icon(
                isListening ? Icons.mic : Icons.mic_none,
                size: 60,
                color: Colors.green,
              ),
              onPressed: () {
                if (isListening) {
                  stopListening();
                } else {
                  startListening();
                }
              },
            ),

            const SizedBox(height: 30),

            const Text(
              "You said:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(userSpeech),

            const SizedBox(height: 20),

            const Text(
              "AI Response:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(aiResponse),
          ],
        ),
      ),
    );
  }
}
