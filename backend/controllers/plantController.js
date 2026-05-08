const OpenAI = require("openai");
const fs = require("fs");
const Query = require("../models/Query");

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

exports.analyzePlant = async (req, res) => {
  try {
    const imagePath = req.file.path;

    const language =
      req.body.language || "English";

    const imageBuffer =
      fs.readFileSync(imagePath);

    const base64Image =
      imageBuffer.toString("base64");

    const languageInstruction =
      language === "English"
        ? `
IMPORTANT:
- Reply ONLY in proper English.
- Never use Hindi words.
- Never use Hinglish.
- Never mix regional words.
`
        : `
IMPORTANT:
- Reply ONLY in ${language}.
- Use native script of ${language}.
- Never use English transliteration.
`;

    const response =
      await openai.chat.completions.create({
        model: "gpt-4o",

        messages: [
          {
            role: "system",

            content: `
You are an expert agricultural scientist.

Analyze plant images and identify diseases.

${languageInstruction}

IMPORTANT RULES:
1. Return ONLY valid JSON.
2. Keep JSON keys ALWAYS in English.
3. Translate ONLY values.
4. No markdown.
5. No explanation outside JSON.
6. Use simple farmer-friendly language.

Return this exact JSON structure:

{
  "disease": "",
  "cause": "",
  "treatment": "",
  "prevention": ""
}

If the plant looks healthy, return:

{
  "disease": "Healthy Plant",
  "cause": "No disease detected",
  "treatment": "No treatment needed",
  "prevention": "Maintain proper watering and nutrients"
}
`,
          },

          {
            role: "user",

            content: [
              {
                type: "text",

                text:
                  "Analyze this plant image. Identify disease and suggest treatment.",
              },

              {
                type: "image_url",

                image_url: {
                  url:
                    `data:image/jpeg;base64,${base64Image}`,
                },
              },
            ],
          },
        ],

        max_tokens: 500,
      });

    let result =
      response.choices?.[0]?.message
        ?.content || "{}";

    result = result
      .replace(/```json/g, "")
      .replace(/```/g, "")
      .trim();

    let parsedResult;

    try {
      parsedResult = JSON.parse(result);
    } catch (err) {
      console.log(
        "Plant JSON Parse Error:",
        err,
      );

      parsedResult = {
        disease:
          language === "Hindi"
            ? "अज्ञात रोग"
            : language === "Punjabi"
            ? "ਅਣਜਾਣ ਬਿਮਾਰੀ"
            : language === "Telugu"
            ? "తెలియని వ్యాధి"
            : language === "Malayalam"
            ? "അറിയാത്ത രോഗം"
            : "Unknown Disease",

        cause:
          language === "Hindi"
            ? "विश्लेषण नहीं हो सका"
            : language === "Punjabi"
            ? "ਵਿਸ਼ਲੇਸ਼ਣ ਨਹੀਂ ਹੋ ਸਕਿਆ"
            : language === "Telugu"
            ? "విశ్లేషణ చేయలేకపోయాము"
            : language === "Malayalam"
            ? "വിശകലനം നടത്താനായില്ല"
            : "Unable to analyze",

        treatment: result,

        prevention:
          language === "Hindi"
            ? "कृपया दूसरी तस्वीर अपलोड करें"
            : language === "Punjabi"
            ? "ਕਿਰਪਾ ਕਰਕੇ ਹੋਰ ਤਸਵੀਰ ਅਪਲੋਡ ਕਰੋ"
            : language === "Telugu"
            ? "దయచేసి మరో చిత్రం అప్లోడ్ చేయండి"
            : language === "Malayalam"
            ? "ദയവായി മറ്റൊരു ചിത്രം അപ്‌ലോഡ് ചെയ്യുക"
            : "Please upload another image",
      };
    }

    await Query.create({
      type: "plant_disease",

      user_input: "plant image",

      response: parsedResult,
    });

    res.json({
      success: true,

      diagnosis: parsedResult,
    });
  } catch (error) {
    console.error(
      "Plant AI Error:",
      error,
    );

    res.status(500).json({
      success: false,

      message:
        "Plant analysis failed",
    });
  }
};