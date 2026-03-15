const Groq = require("groq-sdk");

const groq = new Groq({
apiKey: process.env.GROQ_API_KEY
});

exports.cropRecommendation = async (req, res) => {
try {

    const { location, soil_type, season } = req.body;

    const prompt = `
You are an agricultural expert.

A farmer provides the following information:

Location: ${location}
Soil Type: ${soil_type}
Season: ${season}

Suggest the best crops the farmer should grow.

IMPORTANT:
Return ONLY valid JSON. Do not include explanation or text.

Format:

{
 "recommended_crops": ["crop1", "crop2", "crop3"]
}
`;

    const completion = await groq.chat.completions.create({
    model: "llama-3.1-8b-instant",
    messages: [
        { role: "user", content: prompt }
    ]
    });

    const result = completion.choices[0].message.content;

// convert AI response string into JSON
    const parsedResult = JSON.parse(result);
    
    res.json({
        success: true,
        recommended_crops: parsedResult.recommended_crops
    });

} catch (error) {

    console.error("Crop AI Error:", error);

    res.status(500).json({
    success: false,
    message: "Crop recommendation failed"
    });
}
};