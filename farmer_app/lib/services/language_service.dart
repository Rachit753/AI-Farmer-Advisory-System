import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static Future<String> getLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString("language") ?? "English";
  }

  static Future<String> getSpeechLocale() async {
    String language = await getLanguage();

    switch (language) {
      case "Hindi":
        return "hi-IN";

      case "Punjabi":
        return "pa-IN";

      case "Telugu":
        return "te-IN";

      case "Malayalam":
        return "ml-IN";

      default:
        return "en-US";
    }
  }
}
