const mongoose = require("mongoose");

const farmerSchema = new mongoose.Schema({

name: {
    type: String,
    required: true
},

phone: {
    type: String,
    required: true
},

location: {
    type: String
},

soil_type: {
    type: String
},

primary_crop: {
    type: String
},

preferred_language: {
    type: String,
    default: "English"
},

created_at: {
    type: Date,
    default: Date.now
}

});

module.exports = mongoose.model("Farmer", farmerSchema);