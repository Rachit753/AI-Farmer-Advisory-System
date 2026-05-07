const Farmer = require("../models/Farmer");

exports.loginFarmer = async (req, res) => {
  try {
    const {
      phone,
      state,
      city,
      language,
    } = req.body;

    let farmer = await Farmer.findOne({ phone });

    if (!farmer) {
      farmer = await Farmer.create({
        phone,
        state,
        city,
        preferred_language: language,
      });
    } else {
      farmer.state = state;
      farmer.city = city;
      farmer.preferred_language = language;

      await farmer.save();
    }

    res.json({
      success: true,

      farmer_id: farmer._id,

      farmer,
    });
  } catch (error) {
    console.log(error);

    res.status(500).json({
      success: false,
      message: "Login failed",
    });
  }
};