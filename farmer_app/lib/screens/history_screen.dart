import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/glass_container.dart';
import 'chat_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List history = [];

  bool loading = true;

  Future fetchHistory() async {
    try {
      var response = await http.get(
        Uri.parse(
          "https://ai-farmer-advisory-backend.onrender.com/api/history",
        ),
      );

      var data = jsonDecode(response.body);

      setState(() {
        history = data["history"] ?? [];

        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  Future deleteHistory(String id, int index) async {
    try {
      await http.delete(
        Uri.parse(
          "https://ai-farmer-advisory-backend.onrender.com/api/history/$id",
        ),
      );

      setState(() {
        history.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chat deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to delete chat")));
    }
  }

  @override
  void initState() {
    super.initState();

    fetchHistory();
  }

  Widget buildHistoryItem(item, int index) {
    return FadeInUp(
      delay: Duration(milliseconds: 100 * index),

      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,

            MaterialPageRoute(
              builder: (context) =>
                  ChatScreen(initialQuestion: item["user_input"]),
            ),
          );
        },

        child: Container(
          margin: const EdgeInsets.only(bottom: 18),

          child: GlassContainer(
            child: Row(
              children: [
                Container(
                  height: 65,
                  width: 65,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),

                    gradient: const LinearGradient(
                      colors: [Color(0xff43CEA2), Color(0xff185A9D)],
                    ),
                  ),

                  child: const Icon(
                    Icons.history,

                    color: Colors.white,

                    size: 30,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        item["type"] ?? "AI Query",

                        style: const TextStyle(
                          color: Colors.white,

                          fontSize: 18,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        item["user_input"] ?? "Image Query",

                        maxLines: 2,

                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),

                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        bool confirm =
                            await showDialog(
                              context: context,

                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: const Color(0xff1E1E1E),

                                  title: const Text(
                                    "Delete Chat",

                                    style: TextStyle(color: Colors.white),
                                  ),

                                  content: const Text(
                                    "Are you sure you want to delete this chat?",

                                    style: TextStyle(color: Colors.white70),
                                  ),

                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },

                                      child: const Text("Cancel"),
                                    ),

                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },

                                      child: const Text(
                                        "Delete",

                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ) ??
                            false;

                        if (confirm) {
                          deleteHistory(item["_id"], index);
                        }
                      },

                      child: Container(
                        padding: const EdgeInsets.all(8),

                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),

                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: const Icon(
                          Icons.delete,

                          color: Colors.redAccent,

                          size: 22,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Icon(
                      Icons.arrow_forward_ios,

                      color: Colors.white70,

                      size: 18,
                    ),
                  ],
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
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset("assets/images/history.jpg", fit: BoxFit.cover),
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

                        const Text(
                          "Query History",

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

                  Expanded(
                    child: loading
                        ? const Center(child: CircularProgressIndicator())
                        : history.isEmpty
                        ? Center(
                            child: GlassContainer(
                              child: const Padding(
                                padding: EdgeInsets.all(25),

                                child: Column(
                                  mainAxisSize: MainAxisSize.min,

                                  children: [
                                    Icon(
                                      Icons.history_toggle_off,

                                      size: 70,

                                      color: Colors.white,
                                    ),

                                    SizedBox(height: 15),

                                    Text(
                                      "No History Found",

                                      style: TextStyle(
                                        color: Colors.white,

                                        fontSize: 18,

                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: history.length,

                            itemBuilder: (context, index) {
                              return buildHistoryItem(history[index], index);
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
