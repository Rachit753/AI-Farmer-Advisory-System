import 'package:flutter/material.dart';

import 'chat_screen.dart';
import 'plant_disease_screen.dart';
import 'weather_screen.dart';
import 'crop_recommendation_screen.dart';
import 'history_screen.dart';
import 'voice_assistant_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Widget buildButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.green),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Farmer Dashboard"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            buildButton(context, "Ask AI", Icons.chat, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            }),

            buildButton(context, "Plant Disease", Icons.local_florist, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlantDiseaseScreen(),
                ),
              );
            }),

            buildButton(context, "Crop Recommendation", Icons.agriculture, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CropRecommendationScreen(),
                ),
              );
            }),

            buildButton(context, "Weather", Icons.cloud, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WeatherScreen()),
              );
            }),

            buildButton(context, "History", Icons.history, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            }),

            buildButton(context, "Voice Assistant", Icons.mic, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VoiceAssistantScreen(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
