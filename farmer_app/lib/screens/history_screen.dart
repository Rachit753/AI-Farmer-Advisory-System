import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
    var response = await http.get(
      Uri.parse("http://localhost:5000/api/history"),
    );

    var data = jsonDecode(response.body);

    setState(() {
      history = data["history"];
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Widget buildHistoryItem(item) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.history),
        title: Text(item["type"]),
        subtitle: Text(item["user_input"] ?? "Image Query"),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ChatScreen(initialQuestion: item["user_input"]),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Query History"),
        backgroundColor: Colors.green,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                return buildHistoryItem(history[index]);
              },
            ),
    );
  }
}
