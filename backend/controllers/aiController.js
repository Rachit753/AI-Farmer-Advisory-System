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

    if (!question || question.trim() === "") {
      return res.status(400).json({
        success: false,
        message: "Question is required",
      });
    }

    let farmer = null;

    if (farmer_id) {
      farmer = await Farmer.findById(farmer_id);
    }

    let preferredLanguage =
      language?.trim() ||
      farmer?.preferred_language ||
      "English";

    preferredLanguage =
      preferredLanguage.charAt(0).toUpperCase() +
      preferredLanguage.slice(1).toLowerCase();

    const languageInstruction =
      preferredLanguage === "English"
        ? `
IMPORTANT:
- Reply ONLY in proper English.
- Never use Hindi words.
- Never use Hinglish.
- Never mix regional words.
- Use only pure English sentences.
`
        : `
IMPORTANT:
- Reply ONLY in ${preferredLanguage}.
- Use native script of ${preferredLanguage}.
- Never use English transliteration.
`;

    const completion =
      await groq.chat.completions.create({
        model: "llama-3.1-8b-instant",

        temperature: 0.3,

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

${languageInstruction}

GLOBAL RULES:

1. Keep JSON keys ALWAYS in English.
2. Translate ONLY the values.
3. Return ONLY valid JSON.
4. No markdown.
5. No explanations outside JSON.
6. Use simple farmer-friendly language.
7. Keep sentences short.
8. Response should sound natural and human.
9. Never translate JSON field names.

If voice_mode is true:
- Speak conversationally.
- Avoid robotic formatting.
- Make response natural for speech.

Return ONLY this exact JSON structure:

{
  "problem": "",
  "possible_causes": [],
  "treatment": "",
  "fertilizer": "",
  "pesticide": "",
  "prevention": ""
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

    aiResponse = aiResponse
      .replace(/```json/g, "")
      .replace(/```/g, "")
      .trim();

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