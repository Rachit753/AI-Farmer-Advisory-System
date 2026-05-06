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

      const prompt = `
You are an agricultural expert.

Farmer Details:
Location: ${location}
Soil Type: ${soil_type}
Season: ${season}

Suggest best crops.

IMPORTANT RULES:
1. Return ONLY valid JSON.
2. Do NOT write explanation outside JSON.
3. Crop names must be in ${language}.
4. Use native language script.

JSON format:

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

          temperature: 0,

          messages: [
            {
              role: "user",
              content: prompt,
            },
          ],
        });

      let result =
        completion.choices[0].message
          .content;

      console.log(
        "AI RAW RESPONSE:",
        result,
      );

      result = result.trim();

      result = result.replace(
        /```json/g,
        "",
      );

      result = result.replace(
        /```/g,
        "",
      );

      let parsedResult;

      try {
        parsedResult =
          JSON.parse(result);
      } catch (err) {
        console.log(
          "JSON Parse Failed",
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
            .recommended_crops ||
          [],
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