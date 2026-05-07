const express = require("express");

const router = express.Router();

const {
  loginFarmer,
} = require("../controllers/authController");

router.post("/login", loginFarmer);

module.exports = router;