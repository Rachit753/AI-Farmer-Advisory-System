import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:convert';

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

  List messages = [];

  @override
  void initState() {
    super.initState();

    if (widget.initialQuestion != null) {
      sendMessage(widget.initialQuestion!);
    }
  }

  Future sendMessage(String question) async {
    if (question.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": question});
    });

    controller.clear();

    var response = await http.post(
      Uri.parse("http://localhost:5000/api/ask"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "farmer_id": "69b67016036ad4d9da8b0537",
        "question": question,
      }),
    );

    var data = jsonDecode(response.body);

    setState(() {
      messages.add({"role": "ai", "text": data["result"]["treatment"]});
    });
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

    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.green : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message["text"],
          style: TextStyle(color: isUser ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Farmer Assistant"),
        backgroundColor: Colors.green,
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return messageBubble(messages[index]);
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Ask about crops...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    sendMessage(controller.text);
                  },
                ),

                IconButton(
                  icon: Icon(
                    isListening ? Icons.mic : Icons.mic_none,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
