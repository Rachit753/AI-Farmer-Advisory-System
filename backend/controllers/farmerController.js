const Farmer = require("../models/Farmer");

exports.registerFarmer = async (req, res) => {
  try {
    const {
      name,
      phone,
      state,
      city,
      location,
      soil_type,
      primary_crop,
      preferred_language,
    } = req.body;

    let farmer = await Farmer.findOne({ phone });

    if (farmer) {
      farmer.preferred_language = preferred_language;
      farmer.state = state;
      farmer.city = city;
      farmer.location = location;

      await farmer.save();
    } else {
      farmer = await Farmer.create({
        name,
        phone,
        state,
        city,
        location,
        soil_type,
        primary_crop,
        preferred_language,
      });
    }

    res.json({
      success: true,
      farmer,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Farmer registration failed",
    });
  }
};

exports.getFarmerProfile = async (req, res) => {
  try {
    const farmer = await Farmer.findById(req.params.id);

    res.json({
      success: true,
      farmer,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Profile fetch failed",
    });
  }
};

exports.updateFarmerProfile = async (req, res) => {
  try {
    const farmer = await Farmer.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );

    res.json({
      success: true,
      farmer,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Profile update failed",
    });
  }
};