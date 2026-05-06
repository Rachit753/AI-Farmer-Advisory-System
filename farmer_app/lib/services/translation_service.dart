class TranslationService {
  static Map<String, Map<String, String>> translations = {
    "English": {
      "dashboard": "Farmer Dashboard",
      "ask_ai": "Ask AI",
      "weather": "Weather",
      "crop": "Crop Recommendation",
      "history": "History",
      "voice": "Voice Assistant",
      "plant": "Plant Disease",
      "profile": "Profile",

      // WEATHER SCREEN
      "city": "City",
      "temperature": "Temperature",
      "humidity": "Humidity",
      "weather_label": "Weather",
      "farming_advice": "Farming Advice",
      "enter_city": "Enter City",
      "check_weather": "Check Weather",
    },

    "Hindi": {
      "dashboard": "किसान डैशबोर्ड",
      "ask_ai": "AI से पूछें",
      "weather": "मौसम",
      "crop": "फसल सुझाव",
      "history": "इतिहास",
      "voice": "वॉइस असिस्टेंट",
      "plant": "पौधा रोग",
      "profile": "प्रोफाइल",

      // WEATHER SCREEN
      "city": "शहर",
      "temperature": "तापमान",
      "humidity": "नमी",
      "weather_label": "मौसम",
      "farming_advice": "खेती सलाह",
      "enter_city": "शहर दर्ज करें",
      "check_weather": "मौसम देखें",
    },

    "Punjabi": {
      "dashboard": "ਕਿਸਾਨ ਡੈਸ਼ਬੋਰਡ",
      "ask_ai": "AI ਨੂੰ ਪੁੱਛੋ",
      "weather": "ਮੌਸਮ",
      "crop": "ਫਸਲ ਸਿਫਾਰਸ਼",
      "history": "ਇਤਿਹਾਸ",
      "voice": "ਆਵਾਜ਼ ਸਹਾਇਕ",
      "plant": "ਪੌਦੇ ਦੀ ਬਿਮਾਰੀ",
      "profile": "ਪ੍ਰੋਫਾਈਲ",

      // WEATHER SCREEN
      "city": "ਸ਼ਹਿਰ",
      "temperature": "ਤਾਪਮਾਨ",
      "humidity": "ਨਮੀ",
      "weather_label": "ਮੌਸਮ",
      "farming_advice": "ਖੇਤੀ ਸਲਾਹ",
      "enter_city": "ਸ਼ਹਿਰ ਦਰਜ ਕਰੋ",
      "check_weather": "ਮੌਸਮ ਵੇਖੋ",
    },

    "Telugu": {
      "dashboard": "రైతు డ్యాష్‌బోర్డ్",
      "ask_ai": "AI ని అడగండి",
      "weather": "వాతావరణం",
      "crop": "పంట సూచన",
      "history": "చరిత్ర",
      "voice": "వాయిస్ అసిస్టెంట్",
      "plant": "మొక్క వ్యాధి",
      "profile": "ప్రొఫైల్",

      // WEATHER SCREEN
      "city": "నగరం",
      "temperature": "ఉష్ణోగ్రత",
      "humidity": "ఆర్ద్రత",
      "weather_label": "వాతావరణం",
      "farming_advice": "వ్యవసాయ సలహా",
      "enter_city": "నగరాన్ని నమోదు చేయండి",
      "check_weather": "వాతావరణాన్ని చూడండి",
    },

    "Malayalam": {
      "dashboard": "കർഷക ഡാഷ്ബോർഡ്",
      "ask_ai": "AIയോട് ചോദിക്കുക",
      "weather": "കാലാവസ്ഥ",
      "crop": "വിള നിർദ്ദേശം",
      "history": "ചരിത്രം",
      "voice": "വോയ്സ് അസിസ്റ്റന്റ്",
      "plant": "സസ്യ രോഗം",
      "profile": "പ്രൊഫൈൽ",

      // WEATHER SCREEN
      "city": "നഗരം",
      "temperature": "താപനില",
      "humidity": "ഈർപ്പം",
      "weather_label": "കാലാവസ്ഥ",
      "farming_advice": "കൃഷി നിർദേശം",
      "enter_city": "നഗരം നൽകുക",
      "check_weather": "കാലാവസ്ഥ പരിശോധിക്കുക",
    },
  };

  static String getText(String language, String key) {
    return translations[language]?[key] ?? key;
  }
}
