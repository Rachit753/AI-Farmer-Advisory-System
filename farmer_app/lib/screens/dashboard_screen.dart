import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/translation_service.dart';

import '../widgets/glass_container.dart';

import 'chat_screen.dart';
import 'crop_recommendation_screen.dart';
import 'history_screen.dart';
import 'plant_disease_screen.dart';
import 'profile_screen.dart';
import 'voice_assistant_screen.dart';
import 'weather_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String language = "English";

  String city = "";

  String phone = "";

  @override
  void initState() {
    super.initState();

    loadUserData();
  }

  Future loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      language = prefs.getString("language") ?? "English";

      city = prefs.getString("city") ?? "";

      phone = prefs.getString("phone") ?? "";
    });
  }

  Widget buildDashboardCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required int delay,
  }) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),

      child: GestureDetector(
        onTap: onTap,

        child: GlassContainer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade700],
                  ),
                ),

                child: Icon(icon, size: 34, color: Colors.white),
              ),

              const SizedBox(height: 18),

              Text(
                title,

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
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
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              "assets/images/dashboard.jpg",
              fit: BoxFit.cover,
            ),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,

                colors: [
                  Colors.black.withOpacity(0.55),
                  Colors.green.withOpacity(0.35),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),

              child: Column(
                children: [
                  FadeInDown(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                TranslationService.getText(
                                  language,
                                  "dashboard",
                                ),

                                style: const TextStyle(
                                  color: Colors.white,

                                  fontSize: 28,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                city,

                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),

                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                        GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );

                            loadUserData();
                          },

                          child: Hero(
                            tag: "profile",

                            child: CircleAvatar(
                              radius: 28,

                              backgroundColor: Colors.white.withOpacity(0.2),

                              child: Text(
                                phone.isNotEmpty
                                    ? phone.substring(phone.length - 2)
                                    : "U",

                                style: const TextStyle(
                                  color: Colors.white,

                                  fontSize: 18,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  FadeInDown(
                    delay: const Duration(milliseconds: 200),

                    child: GlassContainer(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade400,
                                  Colors.green.shade800,
                                ],
                              ),
                            ),

                            child: const Icon(
                              Icons.agriculture,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  TranslationService.getText(
                                    language,
                                    "profile",
                                  ),

                                  style: const TextStyle(
                                    color: Colors.white,

                                    fontSize: 18,

                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  city,

                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,

                      crossAxisSpacing: 18,

                      mainAxisSpacing: 18,

                      childAspectRatio: 0.95,

                      children: [
                        buildDashboardCard(
                          title: TranslationService.getText(language, "ask_ai"),

                          icon: Icons.chat,

                          delay: 100,

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChatScreen(),
                              ),
                            );
                          },
                        ),

                        buildDashboardCard(
                          title: TranslationService.getText(
                            language,
                            "weather",
                          ),

                          icon: Icons.cloud_queue,

                          delay: 200,

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WeatherScreen(),
                              ),
                            );
                          },
                        ),

                        buildDashboardCard(
                          title: TranslationService.getText(language, "crop"),

                          icon: Icons.agriculture,

                          delay: 300,

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const CropRecommendationScreen(),
                              ),
                            );
                          },
                        ),

                        buildDashboardCard(
                          title: TranslationService.getText(language, "plant"),

                          icon: Icons.local_florist,

                          delay: 400,

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PlantDiseaseScreen(),
                              ),
                            );
                          },
                        ),

                        buildDashboardCard(
                          title: TranslationService.getText(language, "voice"),

                          icon: Icons.mic,

                          delay: 500,

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const VoiceAssistantScreen(),
                              ),
                            );
                          },
                        ),

                        buildDashboardCard(
                          title: TranslationService.getText(
                            language,
                            "history",
                          ),

                          icon: Icons.history,

                          delay: 600,

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HistoryScreen(),
                              ),
                            );
                          },
                        ),
                      ],
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
