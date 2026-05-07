import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../services/translation_service.dart';
import '../widgets/glass_container.dart';

class ChatScreen extends StatefulWidget {
  final String? initialQuestion;

  const ChatScreen({super.key, this.initialQuestion});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();

  final SpeechToText speech = SpeechToText();

  bool isListening = false;

  bool loading = false;

  List messages = [];

  String language = "English";

  @override
  void initState() {
    super.initState();

    loadLanguage();

    if (widget.initialQuestion != null) {
      sendMessage(widget.initialQuestion!);
    }
  }

  Future loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      language = prefs.getString("language") ?? "English";
    });
  }

  Future sendMessage(String question) async {
    if (question.trim().isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": question});

      loading = true;
    });

    controller.clear();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String farmerId = prefs.getString("farmer_id") ?? "";

      var response = await http.post(
        Uri.parse("https://ai-farmer-advisory-backend.onrender.com/api/ask-ai"),

        headers: {"Content-Type": "application/json"},

        body: jsonEncode({
          "farmer_id": farmerId,

          "question": question,

          "language": language,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        var result = data["result"];

        String formattedResponse =
            """
${result["problem"]}

${result["treatment"]}

${result["fertilizer"]}

${result["prevention"]}
""";

        setState(() {
          messages.add({"role": "ai", "text": formattedResponse});

          loading = false;
        });
      } else {
        setState(() {
          messages.add({
            "role": "ai",
            "text": "Failed to get response from server.",
          });

          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        messages.add({
          "role": "ai",
          "text": "Something went wrong. Please try again.",
        });

        loading = false;
      });
    }
  }

  Future startListening() async {
    bool available = await speech.initialize();

    if (available) {
      setState(() {
        isListening = true;
      });

      speech.listen(
        onResult: (result) {
          setState(() {
            controller.text = result.recognizedWords;
          });
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

  Widget messageBubble(message) {
    bool isUser = message["role"] == "user";

    return FadeInUp(
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,

        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),

          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),

          child: GlassContainer(
            borderRadius: 24,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,

                      backgroundColor: isUser
                          ? Colors.green
                          : Colors.white.withOpacity(0.2),

                      child: Icon(
                        isUser ? Icons.person : Icons.smart_toy,

                        color: Colors.white,

                        size: 18,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Text(
                      isUser ? "You" : "Agri AI",

                      style: const TextStyle(
                        color: Colors.white,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Text(
                  message["text"],

                  style: const TextStyle(
                    color: Colors.white,

                    fontSize: 16,

                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset("assets/images/chat.jpg", fit: BoxFit.cover),
          ),

          Container(color: Colors.black.withOpacity(0.65)),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),

                  child: FadeInDown(
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
                          TranslationService.getText(language, "ask_ai"),

                          style: const TextStyle(
                            color: Colors.white,

                            fontSize: 28,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),

                    itemCount: messages.length,

                    itemBuilder: (context, index) {
                      return messageBubble(messages[index]);
                    },
                  ),
                ),

                if (loading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),

                    child: CircularProgressIndicator(),
                  ),

                Padding(
                  padding: const EdgeInsets.all(16),

                  child: GlassContainer(
                    borderRadius: 30,

                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,

                            style: const TextStyle(color: Colors.white),

                            decoration: InputDecoration(
                              hintText: language == "Hindi"
                                  ? "अपना सवाल पूछें..."
                                  : "Ask farming question...",

                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),

                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            if (isListening) {
                              stopListening();
                            } else {
                              startListening();
                            }
                          },

                          child: Container(
                            padding: const EdgeInsets.all(12),

                            decoration: const BoxDecoration(
                              color: Colors.green,

                              shape: BoxShape.circle,
                            ),

                            child: Icon(
                              isListening ? Icons.mic : Icons.mic_none,

                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        GestureDetector(
                          onTap: () {
                            sendMessage(controller.text);
                          },

                          child: Container(
                            padding: const EdgeInsets.all(12),

                            decoration: const BoxDecoration(
                              color: Colors.green,

                              shape: BoxShape.circle,
                            ),

                            child: const Icon(Icons.send, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
