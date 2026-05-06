const express = require("express");
const router = express.Router();

const {
  registerFarmer,
  getFarmerProfile,
  updateFarmerProfile,
} = require("../controllers/farmerController");

router.post("/farmer/register", registerFarmer);

router.get("/farmer/profile/:id", getFarmerProfile);

router.put("/farmer/profile/:id", updateFarmerProfile);

module.exports = router;