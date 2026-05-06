import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const FarmerApp());
}

class FarmerApp extends StatefulWidget {
  const FarmerApp({super.key});

  @override
  State<FarmerApp> createState() => _FarmerAppState();
}

class _FarmerAppState extends State<FarmerApp> {
  bool isLoggedIn = false;

  bool loading = true;

  @override
  void initState() {
    super.initState();

    checkLogin();
  }

  Future checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool logged = prefs.getBool("isLoggedIn") ?? false;

    setState(() {
      isLoggedIn = logged;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final baseTheme = ThemeData.dark();

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: baseTheme.copyWith(
        scaffoldBackgroundColor: const Color(0xff081C15),

        textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,

          fillColor: Colors.white.withOpacity(0.08),

          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),

          labelStyle: const TextStyle(color: Colors.white),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),

            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),

            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),

            borderSide: const BorderSide(color: Colors.green, width: 1.5),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,

            foregroundColor: Colors.white,

            elevation: 0,

            padding: const EdgeInsets.symmetric(vertical: 16),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),

      home: isLoggedIn ? const DashboardScreen() : const LoginScreen(),
    );
  }
}
