const Groq = require("groq-sdk");
const Query = require("../models/Query");
const Farmer = require("../models/Farmer");

const groq = new Groq({
  apiKey: process.env.GROQ_API_KEY
});

exports.askAI = async (req, res) => {
  try {

    const { farmer_id, question } = req.body;

    if (!question) {
      return res.status(400).json({
        success: false,
        message: "Question is required"
      });
    }

    // Fetch farmer profile
    let farmer = null;

    if (farmer_id) {
      farmer = await Farmer.findById(farmer_id);
    }

    // AI request
    const chatCompletion = await groq.chat.completions.create({
      model: "llama-3.1-8b-instant",
      messages: [
        {
          role: "system",
          content: `
You are an agricultural expert helping farmers.

Farmer profile:
Location: ${farmer?.location || "Unknown"}
Soil Type: ${farmer?.soil_type || "Unknown"}
Primary Crop: ${farmer?.primary_crop || "Unknown"}
Preferred Language: ${farmer?.preferred_language || "English"}

Answer the farmer question in the farmer's preferred language.

Supported languages:
English
Hindi
Punjabi
Telugu
Malayalam

Return response strictly in JSON format:

{
"problem": "",
"possible_causes": [],
"treatment": "",
"fertilizer": "",
"pesticide": "",
"prevention": ""
}

Rules:
Return ONLY JSON.
Do not include explanations outside JSON.
Use simple language for farmers.
`
        },
        {
          role: "user",
          content: question
        }
      ]
    });

    const aiResponse =
      chatCompletion.choices?.[0]?.message?.content || "{}";

    let parsedResult;

    try {
      parsedResult = JSON.parse(aiResponse);
    } catch (err) {

      parsedResult = {
        problem: question,
        possible_causes: [],
        treatment: aiResponse,
        fertilizer: "Not specified",
        pesticide: "Not specified",
        prevention: "Follow good farming practices"
      };

    }

    // Save query history
    await Query.create({
      farmer_id: farmer_id || null,
      type: "chat",
      user_input: question,
      response: parsedResult
    });

    res.json({
      success: true,
      result: parsedResult
    });

  } catch (error) {

    console.error("Groq Error:", error);

    res.status(500).json({
      success: false,
      message: "AI response failed"
    });

  }
};