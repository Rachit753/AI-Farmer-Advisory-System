import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/glass_container.dart';
import 'dashboard_screen.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();

  final TextEditingController otpController = TextEditingController();

  final TextEditingController stateController = TextEditingController();

  final TextEditingController cityController = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;

  bool otpSent = false;

  bool loading = false;

  int secondsRemaining = 60;

  Timer? timer;

  String verificationId = "";

  String selectedLanguage = "English";

  void startTimer() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() {
          secondsRemaining--;
        });
      }
    });
  }

  Future sendOTP() async {
    if (phoneController.text.isEmpty) return;

    setState(() {
      loading = true;
    });

    await auth.verifyPhoneNumber(
      phoneNumber: "+91${phoneController.text}",

      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
      },

      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          loading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Verification Failed")),
        );
      },

      codeSent: (String verId, int? resendToken) {
        setState(() {
          otpSent = true;
          loading = false;
          verificationId = verId;
          secondsRemaining = 60;
        });

        startTimer();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("OTP Sent Successfully")));
      },

      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );
  }

  Future verifyOTP() async {
    try {
      setState(() {
        loading = true;
      });

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpController.text,
      );

      await auth.signInWithCredential(credential);

      var response = await http.post(
        Uri.parse(
          "https://ai-farmer-advisory-backend.onrender.com/api/auth/login",
        ),

        headers: {"Content-Type": "application/json"},

        body: jsonEncode({
          "phone": phoneController.text,

          "state": stateController.text,

          "city": cityController.text,

          "language": selectedLanguage,
        }),
      );

      var data = jsonDecode(response.body);

      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setBool("isLoggedIn", true);

      await prefs.setString("phone", phoneController.text);

      await prefs.setString("language", selectedLanguage);

      await prefs.setString("state", stateController.text);

      await prefs.setString("city", cityController.text);

      await prefs.setString("farmer_id", data["farmer_id"]);

      print("Farmer ID Saved: ${data["farmer_id"]}");

      setState(() {
        loading = false;
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      print("Login Error: $e");

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid OTP")));
    }
  }

  @override
  void dispose() {
    timer?.cancel();

    phoneController.dispose();
    otpController.dispose();
    stateController.dispose();
    cityController.dispose();

    super.dispose();
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,

      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset("assets/images/main.jpg", fit: BoxFit.cover),
          ),

          Container(color: Colors.black.withOpacity(0.45)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [
                  const SizedBox(height: 50),

                  FadeInDown(
                    child: const Text(
                      "AI Farmer",
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  FadeInDown(
                    delay: const Duration(milliseconds: 300),
                    child: Text(
                      "Smart Farming Assistant",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  FadeInUp(
                    child: GlassContainer(
                      child: Column(
                        children: [
                          buildTextField(
                            controller: phoneController,
                            hint: "Mobile Number",
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 20),

                          if (!otpSent)
                            SizedBox(
                              width: double.infinity,
                              height: 55,

                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),

                                onPressed: loading ? null : sendOTP,

                                child: loading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        "Send OTP",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),

                          if (otpSent) ...[
                            buildTextField(
                              controller: otpController,
                              hint: "Enter OTP",
                              keyboardType: TextInputType.number,
                            ),

                            const SizedBox(height: 15),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "OTP expires in $secondsRemaining sec",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            buildTextField(
                              controller: stateController,
                              hint: "State",
                            ),

                            const SizedBox(height: 20),

                            buildTextField(
                              controller: cityController,
                              hint: "City",
                            ),

                            const SizedBox(height: 20),

                            DropdownButtonFormField(
                              dropdownColor: const Color(0xff102417),

                              value: selectedLanguage,

                              decoration: const InputDecoration(
                                hintText: "Select Language",
                              ),

                              items: const [
                                DropdownMenuItem(
                                  value: "English",
                                  child: Text("English"),
                                ),
                                DropdownMenuItem(
                                  value: "Hindi",
                                  child: Text("Hindi"),
                                ),
                                DropdownMenuItem(
                                  value: "Punjabi",
                                  child: Text("Punjabi"),
                                ),
                                DropdownMenuItem(
                                  value: "Telugu",
                                  child: Text("Telugu"),
                                ),
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

                            const SizedBox(height: 25),

                            SizedBox(
                              width: double.infinity,
                              height: 55,

                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),

                                onPressed: loading ? null : verifyOTP,

                                child: loading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        "Verify OTP",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
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
