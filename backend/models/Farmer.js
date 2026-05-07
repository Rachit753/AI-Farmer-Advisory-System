const mongoose = require("mongoose");

const farmerSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      default: "",
    },

    phone: {
      type: String,
      required: true,
      unique: true,
    },

    state: {
      type: String,
      default: "",
    },

    city: {
      type: String,
      default: "",
    },

    location: {
      type: String,
      default: "",
    },

    soil_type: {
      type: String,
      default: "",
    },

    primary_crop: {
      type: String,
      default: "",
    },

    preferred_language: {
      type: String,
      default: "English",
    },
  },

  {
    timestamps: true,
  }
);

module.exports = mongoose.model(
  "Farmer",
  farmerSchema
);