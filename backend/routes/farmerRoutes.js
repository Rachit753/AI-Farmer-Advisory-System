const express = require("express");
const router = express.Router();

const {
registerFarmer,
getFarmerProfile
} = require("../controllers/farmerController");

router.post("/farmer/register", registerFarmer);

router.get("/farmer/profile/:id", getFarmerProfile);

module.exports = router;