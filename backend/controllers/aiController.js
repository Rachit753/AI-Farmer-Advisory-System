const Groq = require("groq-sdk");

const groq = new Groq({
  apiKey: process.env.GROQ_API_KEY
});

exports.askAI = async (req, res) => {
  try {
    const { question } = req.body;

    const chatCompletion = await groq.chat.completions.create({
      model: "llama-3.1-8b-instant",
      messages: [
        {
          role: "system",
          content: `
                    You are an agricultural expert helping farmers.

                    When answering:
                    • Explain the possible cause
                    • Suggest treatment
                    • Recommend fertilizer or pesticide if needed
                    • Give prevention tips
                    • Keep language simple for farmers
`
        },
        {
          role: "user",
          content: question
        }
      ]
    });

    const answer = chatCompletion.choices[0].message.content;

    res.json({
      success: true,
      answer: answer
    });

  } catch (error) {
    console.error("Groq Error:", error);

    res.status(500).json({
      success: false,
      message: "AI response failed"
    });
  }
};