const Groq = require("groq-sdk");
const Query = require("../models/Query");

const groq = new Groq({
  apiKey: process.env.GROQ_API_KEY,
});

exports.cropRecommendation =
  async (req, res) => {
    try {
      const {
        location,
        soil_type,
        season,
        language,
      } = req.body;

      const preferredLanguage =
        language?.trim() || "English";

      const languageInstruction =
        preferredLanguage === "English"
          ? `
IMPORTANT:
- Return crop names ONLY in English.
- Never use Hindi.
- Never use Hinglish.
- Never mix regional words.
`
          : `
IMPORTANT:
- Return crop names ONLY in ${preferredLanguage}.
- Use native script of ${preferredLanguage}.
- Never use English transliteration.
`;

      const prompt = `
You are an agricultural expert helping farmers.

Farmer Details:
Location: ${location}
Soil Type: ${soil_type}
Season: ${season}

Suggest the best crops suitable for the farmer.

${languageInstruction}

GLOBAL RULES:
1. Return ONLY valid JSON.
2. Do NOT write explanations outside JSON.
3. Keep JSON keys ALWAYS in English.
4. Translate ONLY crop values.
5. Return maximum 6 crops.
6. No markdown.
7. No extra text.

Return ONLY this format:

{
  "recommended_crops": [
    "crop1",
    "crop2",
    "crop3"
  ]
}
`;

      const completion =
        await groq.chat.completions.create({
          model:
            "llama-3.1-8b-instant",

          temperature: 0.2,

          messages: [
            {
              role: "system",
              content: prompt,
            },
          ],
        });

      let result =
        completion.choices?.[0]
          ?.message?.content || "{}";

      console.log(
        "AI RAW RESPONSE:",
        result,
      );

      result = result
        .replace(/```json/g, "")
        .replace(/```/g, "")
        .trim();

      let parsedResult;

      try {
        parsedResult =
          JSON.parse(result);

        if (
          !Array.isArray(
            parsedResult
              .recommended_crops,
          )
        ) {
          parsedResult = {
            recommended_crops: [],
          };
        }
      } catch (err) {
        console.log(
          "JSON Parse Failed",
          err,
        );

        parsedResult = {
          recommended_crops: [
            result,
          ],
        };
      }

      await Query.create({
        type:
          "crop_recommendation",

        user_input:
          `${location} - ${soil_type} - ${season}`,

        response: parsedResult,
      });

      res.json({
        success: true,

        recommended_crops:
          parsedResult
            .recommended_crops || [],
      });
    } catch (error) {
      console.error(
        "Crop AI Error:",
        error,
      );

      res.status(500).json({
        success: false,
        message:
          "Crop recommendation failed",
      });
    }
  };