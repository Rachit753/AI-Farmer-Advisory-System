import 'package:flutter/material.dart';
import 'dart:async';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  bool otpSent = false;
  int secondsRemaining = 60;
  Timer? timer;

  String selectedLanguage = "English";

  void sendOTP() {
    setState(() {
      otpSent = true;
      secondsRemaining = 60;
    });

    startTimer();

    // Here Firebase OTP will be triggered
  }

  void startTimer() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() {
          secondsRemaining--;
        });
      }
    });
  }

  void resendOTP() {
    sendOTP();
  }

  void verifyOTP() {
    // Here Firebase OTP verification will happen

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Farmer Login"),
        backgroundColor: Colors.green,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Mobile Number",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            if (!otpSent)
              ElevatedButton(onPressed: sendOTP, child: const Text("Send OTP")),

            if (otpSent) ...[
              const SizedBox(height: 10),

              TextField(
                controller: otpController,
                decoration: const InputDecoration(
                  labelText: "Enter OTP",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              Text("OTP expires in $secondsRemaining seconds"),

              const SizedBox(height: 10),

              if (secondsRemaining == 0)
                TextButton(
                  onPressed: resendOTP,
                  child: const Text("Resend OTP"),
                ),

              const SizedBox(height: 10),

              DropdownButtonFormField(
                value: selectedLanguage,
                items: const [
                  DropdownMenuItem(value: "English", child: Text("English")),
                  DropdownMenuItem(value: "Hindi", child: Text("Hindi")),
                  DropdownMenuItem(value: "Punjabi", child: Text("Punjabi")),
                  DropdownMenuItem(value: "Telugu", child: Text("Telugu")),
                  DropdownMenuItem(
                    value: "Malayalam",
                    child: Text("Malayalam"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedLanguage = value.toString();
                  });
                },
              ),

              const SizedBox(height: 20),

              ElevatedButton(onPressed: verifyOTP, child: const Text("Login")),
            ],
          ],
        ),
      ),
    );
  }
}
