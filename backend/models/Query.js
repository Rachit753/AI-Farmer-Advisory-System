const mongoose = require("mongoose");

const querySchema = new mongoose.Schema({
type: {
    type: String,
    enum: ["chat", "plant_disease", "crop_recommendation"],
    required: true
},
user_input: {
    type: String
},
response: {
    type: Object
},
created_at: {
    type: Date,
    default: Date.now
}
});

module.exports = mongoose.model("Query", querySchema);