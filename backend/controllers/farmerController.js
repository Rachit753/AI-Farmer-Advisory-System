const Farmer = require("../models/Farmer");

exports.registerFarmer = async (req, res) => {

try {

    const { name, phone, location, soil_type, primary_crop } = req.body;

    const farmer = await Farmer.create({
    name,
    phone,
    location,
    soil_type,
    primary_crop
    });

    res.json({
    success: true,
    farmer
    });

} catch (error) {

    console.error(error);

    res.status(500).json({
    success: false,
    message: "Farmer registration failed"
    });

}

};

exports.getFarmerProfile = async (req, res) => {

try {

    const farmer = await Farmer.findById(req.params.id);

    res.json({
    success: true,
    farmer
    });

} catch (error) {

    res.status(500).json({
    success: false,
    message: "Profile fetch failed"
    });

}

};