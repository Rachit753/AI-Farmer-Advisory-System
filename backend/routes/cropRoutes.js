const express = require("express");
const router = express.Router();

const { cropRecommendation } = require("../controllers/cropController");

router.post("/crop-recommendation", cropRecommendation);

module.exports = router;