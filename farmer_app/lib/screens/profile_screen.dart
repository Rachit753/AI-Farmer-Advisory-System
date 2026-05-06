import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/glass_container.dart';

import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String phone = "";

  final TextEditingController stateController = TextEditingController();

  final TextEditingController cityController = TextEditingController();

  String selectedLanguage = "English";

  @override
  void initState() {
    super.initState();

    loadProfile();
  }

  Future loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      phone = prefs.getString("phone") ?? "";

      stateController.text = prefs.getString("state") ?? "";

      cityController.text = prefs.getString("city") ?? "";

      selectedLanguage = prefs.getString("language") ?? "English";
    });
  }

  Future saveProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString("state", stateController.text);

    await prefs.setString("city", cityController.text);

    await prefs.setString("language", selectedLanguage);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile Updated Successfully")),
    );
  }

  Widget buildField({
    required TextEditingController controller,
    required String hint,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,

      enabled: enabled,

      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      ),
    );
  }

  @override
  void dispose() {
    stateController.dispose();

    cityController.dispose();

    super.dispose();
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

          Container(color: Colors.black.withOpacity(0.55)),

          SafeArea(
            child: SingleChildScrollView(
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
                          "Profile",

                          style: TextStyle(
                            color: Colors.white,

                            fontSize: 28,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  FadeInDown(
                    delay: const Duration(milliseconds: 200),

                    child: Hero(
                      tag: "profile",

                      child: CircleAvatar(
                        radius: 55,

                        backgroundColor: Colors.white.withOpacity(0.2),

                        child: Text(
                          phone.isNotEmpty
                              ? phone.substring(phone.length - 2)
                              : "U",

                          style: const TextStyle(
                            color: Colors.white,

                            fontSize: 30,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  FadeInDown(
                    delay: const Duration(milliseconds: 300),

                    child: Text(
                      "+91 $phone",

                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),

                        fontSize: 18,
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  FadeInUp(
                    child: GlassContainer(
                      child: Column(
                        children: [
                          buildField(
                            controller: stateController,

                            hint: "State",
                          ),

                          const SizedBox(height: 20),

                          buildField(controller: cityController, hint: "City"),

                          const SizedBox(height: 20),

                          DropdownButtonFormField(
                            dropdownColor: const Color(0xff102417),

                            value: selectedLanguage,

                            style: const TextStyle(color: Colors.white),

                            decoration: const InputDecoration(
                              hintText: "Language",
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

                          const SizedBox(height: 30),

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

                              onPressed: saveProfile,

                              child: const Text(
                                "Save Changes",

                                style: TextStyle(
                                  color: Colors.white,

                                  fontSize: 16,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          SizedBox(
                            width: double.infinity,

                            height: 55,

                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),

                              onPressed: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();

                                await prefs.clear();

                                if (!mounted) return;

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              },

                              child: const Text(
                                "Logout",

                                style: TextStyle(
                                  color: Colors.white,

                                  fontSize: 16,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
