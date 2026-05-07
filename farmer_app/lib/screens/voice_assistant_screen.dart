import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../services/language_service.dart';
import '../services/translation_service.dart';
import '../widgets/glass_container.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  final SpeechToText speech = SpeechToText();

  final FlutterTts tts = FlutterTts();

  bool isListening = false;

  bool isSpeaking = false;

  String userSpeech = "";
  String aiResponse = "";

  String language = "English";

  @override
  void initState() {
    super.initState();

    loadLanguage();

    initializeTTS();
  }

  Future initializeTTS() async {
    await tts.awaitSpeakCompletion(true);

    tts.setStartHandler(() {
      if (mounted) {
        setState(() {
          isSpeaking = true;
        });
      }
    });

    tts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          isSpeaking = false;
        });
      }
    });

    tts.setCancelHandler(() {
      if (mounted) {
        setState(() {
          isSpeaking = false;
        });
      }
    });
  }

  Future loadLanguage() async {
    language = await LanguageService.getLanguage();

    setState(() {});
  }

  Future startListening() async {
    bool available = await speech.initialize();

    if (available) {
      String locale = await LanguageService.getSpeechLocale();

      setState(() {
        isListening = true;
      });

      speech.listen(
        localeId: locale,

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
    String language = await LanguageService.getLanguage();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String farmerId = prefs.getString("farmer_id") ?? "";

    var response = await http.post(
      Uri.parse("https://ai-farmer-advisory-backend.onrender.com/api/ask-ai"),

      headers: {"Content-Type": "application/json"},

      body: jsonEncode({
        "farmer_id": farmerId,

        "question": question,

        "language": language,

        "voice_mode": true,
      }),
    );

    print(response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      var result = data["result"];

      String spokenResponse =
          """
${result["problem"]}. 

${result["treatment"]}. 

${result["prevention"]}
""";

      setState(() {
        aiResponse = spokenResponse;
      });

      speak(spokenResponse);
    } else {
      setState(() {
        aiResponse = "Error connecting to AI service.";
      });
    }
  }

  Future speak(String text) async {
    String locale = await LanguageService.getSpeechLocale();

    await tts.stop();

    await tts.setLanguage(locale);

    if (kIsWeb) {
      await tts.setSpeechRate(0.85);
    } else {
      await tts.setSpeechRate(0.45);
    }

    await tts.setPitch(1.0);

    await tts.setVolume(1.0);

    text = text.replaceAll(".", ". ");

    await tts.speak(text);
  }

  @override
  void dispose() {
    speech.stop();

    tts.stop();

    super.dispose();
  }

  Widget buildSection({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,

                  style: const TextStyle(
                    color: Colors.white,

                    fontSize: 18,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Text(
            value.isEmpty ? "..." : value,

            style: const TextStyle(
              color: Colors.white,

              fontSize: 16,

              height: 1.6,
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
            child: Image.asset("assets/images/voice.jpg", fit: BoxFit.cover),
          ),

          Container(color: Colors.black.withOpacity(0.7)),

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

                        Expanded(
                          child: Text(
                            TranslationService.getText(language, "voice"),

                            overflow: TextOverflow.ellipsis,

                            style: const TextStyle(
                              color: Colors.white,

                              fontSize: 28,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  FadeInUp(
                    child: GestureDetector(
                      onTap: () {
                        if (isListening) {
                          stopListening();
                        } else {
                          startListening();
                        }
                      },

                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),

                        height: 150,

                        width: 150,

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,

                          gradient: LinearGradient(
                            colors: isListening
                                ? [Colors.red, Colors.orange]
                                : [Colors.green, Colors.lightGreen],
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: isListening
                                  ? Colors.red.withOpacity(0.5)
                                  : Colors.green.withOpacity(0.5),

                              blurRadius: 30,

                              spreadRadius: 5,
                            ),
                          ],
                        ),

                        child: Icon(
                          isListening ? Icons.mic : Icons.mic_none,

                          size: 70,

                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    language == "Hindi"
                        ? "माइक दबाएं और अपना सवाल पूछें"
                        : language == "Punjabi"
                        ? "ਮਾਈਕ ਦਬਾਓ ਅਤੇ ਆਪਣਾ ਸਵਾਲ ਪੁੱਛੋ"
                        : language == "Telugu"
                        ? "మైక్ నొక్కి మీ ప్రశ్న అడగండి"
                        : language == "Malayalam"
                        ? "മൈക്ക് അമർത്തി നിങ്ങളുടെ ചോദ്യം ചോദിക്കുക"
                        : "Tap the microphone and ask your farming question",

                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      color: Colors.white,

                      fontSize: 18,

                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          buildSection(
                            title: language == "Hindi"
                                ? "आपने कहा:"
                                : language == "Punjabi"
                                ? "ਤੁਸੀਂ ਕਿਹਾ:"
                                : language == "Telugu"
                                ? "మీరు చెప్పారు:"
                                : language == "Malayalam"
                                ? "നിങ്ങൾ പറഞ്ഞു:"
                                : "You said:",

                            value: userSpeech,

                            icon: Icons.person,
                          ),

                          const SizedBox(height: 20),

                          buildSection(
                            title: language == "Hindi"
                                ? "AI उत्तर:"
                                : language == "Punjabi"
                                ? "AI ਜਵਾਬ:"
                                : language == "Telugu"
                                ? "AI సమాధానం:"
                                : language == "Malayalam"
                                ? "AI മറുപടി:"
                                : "AI Response:",

                            value: aiResponse,

                            icon: Icons.smart_toy,
                          ),

                          const SizedBox(height: 25),

                          if (isSpeaking)
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,

                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),

                                    onPressed: () async {
                                      await tts.stop();

                                      setState(() {
                                        isSpeaking = false;
                                      });
                                    },

                                    icon: const Icon(
                                      Icons.stop_circle,

                                      color: Colors.white,
                                    ),

                                    label: Text(
                                      language == "Hindi"
                                          ? "आवाज़ रोकें"
                                          : language == "Punjabi"
                                          ? "ਆਵਾਜ਼ ਰੋਕੋ"
                                          : language == "Telugu"
                                          ? "వాయిస్ ఆపండి"
                                          : language == "Malayalam"
                                          ? "ശബ്ദം നിർത്തുക"
                                          : "Stop Voice",

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
                        ],
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
