const OpenAI = require("openai");
const fs = require("fs");
const Query = require("../models/Query");

const openai = new OpenAI({
apiKey: process.env.OPENAI_API_KEY
});

exports.analyzePlant = async (req, res) => {
try {
    const imagePath = req.file.path;

    
    const imageBuffer = fs.readFileSync(imagePath);
    const base64Image = imageBuffer.toString("base64");

    const response = await openai.chat.completions.create({
    model: "gpt-4o",
    messages: [
        {
        role: "system",
        content: `
You are an expert agricultural scientist.

Analyze plant images and identify diseases.

Return the result strictly in this JSON format:

{
"disease": "name of disease",
"cause": "reason for disease",
"treatment": "recommended treatment or pesticide",
"prevention": "how farmers can prevent it"
}

If the plant looks healthy, return:

{
"disease": "Healthy Plant",
"cause": "No disease detected",
"treatment": "No treatment needed",
"prevention": "Maintain proper watering and nutrients"
}
`
        },
        {
        role: "user",
        content: [
            {
            type: "text",
            text: "Analyze this plant image. Identify possible disease and suggest treatment."
            },
            {
            type: "image_url",
            image_url: {
                url: `data:image/jpeg;base64,${base64Image}`
            }
            }
        ]
        }
    ],
    max_tokens: 500
    });

    const result = response.choices[0].message.content;

    
    await Query.create({
    type: "plant_disease",
    user_input: "plant image",
    response: result
    });

    res.json({
    success: true,
    diagnosis: result
    });

} catch (error) {
    console.error("Plant AI Error:", error);

    res.status(500).json({
    success: false,
    message: "Plant analysis failed"
    });
}
};