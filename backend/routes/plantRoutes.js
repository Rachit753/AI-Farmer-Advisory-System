const express = require("express");
const router = express.Router();

const upload = require("../middleware/upload");
const { analyzePlant } = require("../controllers/plantController");

router.post("/analyze-plant", upload.single("image"), analyzePlant);

module.exports = router;