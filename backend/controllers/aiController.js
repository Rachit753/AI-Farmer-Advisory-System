const Groq = require("groq-sdk");
const Query = require("../models/Query");

const groq = new Groq({
  apiKey: process.env.GROQ_API_KEY
});

exports.askAI = async (req, res) => {
  try {

    const { question } = req.body;

    // Validate input
    if (!question) {
      return res.status(400).json({
        success: false,
        message: "Question is required"
      });
    }

    // Call Groq AI
    const chatCompletion = await groq.chat.completions.create({
      model: "llama-3.1-8b-instant",
      messages: [
        {
          role: "system",
          content: `
You are an agricultural expert helping farmers.

Answer farming questions in STRICT JSON format.

Format:
{
  "problem": "short description of the issue",
  "possible_causes": ["cause1", "cause2", "cause3"],
  "treatment": "recommended treatment",
  "fertilizer": "recommended fertilizer if needed",
  "pesticide": "recommended pesticide if needed",
  "prevention": "how farmers can prevent this problem"
}

Rules:
Return ONLY JSON
Do not include explanations outside JSON
Keep language simple for farmers
`
        },
        {
          role: "user",
          content: question
        }
      ]
    });

    // Get AI response
    const aiResponse =
      chatCompletion.choices?.[0]?.message?.content || "{}";

    let parsedResult;

    // Try to parse AI JSON
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

    // Save to MongoDB
    await Query.create({
      type: "chat",
      user_input: question,
      response: parsedResult
    });

    // Send response
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