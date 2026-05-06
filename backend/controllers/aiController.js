const Groq = require("groq-sdk");
const Query = require("../models/Query");
const Farmer = require("../models/Farmer");

const groq = new Groq({
  apiKey: process.env.GROQ_API_KEY,
});

exports.askAI = async (req, res) => {
  try {
    const {
      farmer_id,
      question,
      language,
      voice_mode,
    } = req.body;

    if (!question) {
      return res.status(400).json({
        success: false,
        message: "Question is required",
      });
    }

    let farmer = null;

    if (farmer_id) {
      farmer = await Farmer.findById(farmer_id);
    }

    const preferredLanguage =
      language ||
      farmer?.preferred_language ||
      "English";

    const completion =
      await groq.chat.completions.create({
        model: "llama-3.1-8b-instant",

        temperature: 0.4,

        messages: [
          {
            role: "system",

            content: `
You are an expert agriculture advisor helping farmers.

Farmer details:
Location: ${farmer?.location || "Unknown"}
State: ${farmer?.state || "Unknown"}
City: ${farmer?.city || "Unknown"}
Soil Type: ${farmer?.soil_type || "Unknown"}
Primary Crop: ${farmer?.primary_crop || "Unknown"}
Preferred Language: ${preferredLanguage}

IMPORTANT RULES:

1. Reply ONLY in ${preferredLanguage}.
2. Use native script of the language.
3. Never use English transliteration.
4. Punjabi must use Gurmukhi script.
5. Hindi must use Devanagari script.
6. Telugu must use Telugu script.
7. Malayalam must use Malayalam script.
8. Use simple farmer friendly language.
9. No markdown.
10. No explanations outside JSON.
11. Response should sound natural and human.
12. Keep sentences short and easy to understand.
13. NEVER translate JSON keys.
14. Keep JSON field names ALWAYS in English.
15. Translate ONLY the values.

If voice_mode is true:
- Speak conversationally like a farming expert.
- Avoid robotic formatting.
- Make response natural for speech.

Return ONLY valid JSON in this EXACT format:

{
  "problem": "",
  "possible_causes": [],
  "treatment": "",
  "fertilizer": "",
  "pesticide": "",
  "prevention": ""
}

Example Hindi response:

{
  "problem": "गेहूं में कीड़े लगना",
  "possible_causes": ["भूमि की गुणवत्ता खराब"],
  "treatment": "कीड़े नाशक दवाओं का उपयोग करें",
  "fertilizer": "जैविक खाद का उपयोग करें",
  "pesticide": "फॉर्मलिन",
  "prevention": "बीज की गुणवत्ता जांचें"
}
`,
          },

          {
            role: "user",
            content: question,
          },
        ],
      });

    let aiResponse =
      completion.choices?.[0]?.message?.content || "{}";

    aiResponse = aiResponse.replace(/```json/g, "");
    aiResponse = aiResponse.replace(/```/g, "");
    aiResponse = aiResponse.trim();

    let parsedResult;

    try {
      parsedResult = JSON.parse(aiResponse);

      parsedResult = {
        problem:
          parsedResult.problem ||
          parsedResult["समस्या"] ||
          parsedResult["ਸਮੱਸਿਆ"] ||
          parsedResult["సమస్య"] ||
          parsedResult["പ്രശ്നം"] ||
          "",

        possible_causes:
          parsedResult.possible_causes ||
          parsedResult["संभावित कारण"] ||
          parsedResult["ਸੰਭਾਵਿਤ ਕਾਰਨ"] ||
          parsedResult["సంభావ్య కారణాలు"] ||
          parsedResult["സാധ്യമായ കാരണങ്ങൾ"] ||
          [],

        treatment:
          parsedResult.treatment ||
          parsedResult["उपचार"] ||
          parsedResult["ਚਿਕਿਤ्सा"] ||
          parsedResult["చికిత్స"] ||
          parsedResult["ചികിത്സ"] ||
          "",

        fertilizer:
          parsedResult.fertilizer ||
          parsedResult["खाद"] ||
          parsedResult["ਖਾਦ"] ||
          parsedResult["ఎరువు"] ||
          parsedResult["വളം"] ||
          "",

        pesticide:
          parsedResult.pesticide ||
          parsedResult["कीटनाशक"] ||
          parsedResult["ਕੀਟਨਾਸ਼ਕ"] ||
          parsedResult["పురుగుమందు"] ||
          parsedResult["കീടനാശിനി"] ||
          "",

        prevention:
          parsedResult.prevention ||
          parsedResult["रोकथाम"] ||
          parsedResult["ਰੋਕਥਾਮ"] ||
          parsedResult["నివారణ"] ||
          parsedResult["പ്രതിരോധം"] ||
          "",
      };
    } catch (err) {
      console.log("JSON Parse Error:", err);

      parsedResult = {
        problem: question,

        possible_causes: [],

        treatment: aiResponse,

        fertilizer:
          preferredLanguage === "Hindi"
              ? "उल्लेख नहीं"
              : preferredLanguage === "Punjabi"
              ? "ਉਲੇਖ ਨਹੀਂ"
              : preferredLanguage === "Telugu"
              ? "పేర్కొనలేదు"
              : preferredLanguage === "Malayalam"
              ? "പരാമർശിച്ചിട്ടില്ല"
              : "Not specified",

        pesticide:
          preferredLanguage === "Hindi"
              ? "उल्लेख नहीं"
              : preferredLanguage === "Punjabi"
              ? "ਉਲੇਖ ਨਹੀਂ"
              : preferredLanguage === "Telugu"
              ? "పేర్కొనలేదు"
              : preferredLanguage === "Malayalam"
              ? "പരാമർശിച്ചിട്ടില്ല"
              : "Not specified",

        prevention:
          preferredLanguage === "Hindi"
              ? "अच्छी खेती पद्धतियों का पालन करें"
              : preferredLanguage === "Punjabi"
              ? "ਚੰਗੀਆਂ ਖੇਤੀ ਪੱਧਤੀਆਂ ਦੀ ਪਾਲਣਾ ਕਰੋ"
              : preferredLanguage === "Telugu"
              ? "మంచి వ్యవసాయ పద్ధతులను అనుసరించండి"
              : preferredLanguage === "Malayalam"
              ? "നല്ല കൃഷി രീതികൾ പിന്തുടരുക"
              : "Follow good farming practices",
      };
    }

    await Query.create({
      farmer_id: farmer_id || null,

      type: "chat",

      user_input: question,

      response: parsedResult,
    });

    res.json({
      success: true,

      result: parsedResult,
    });
  } catch (error) {
    console.error("AI Error:", error);

    res.status(500).json({
      success: false,
      message: "AI response failed",
    });
  }
};