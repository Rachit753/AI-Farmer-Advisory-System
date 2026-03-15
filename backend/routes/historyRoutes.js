const express = require("express");
const router = express.Router();
const Query = require("../models/Query");

router.get("/history", async (req, res) => {

try {

    const history = await Query.find().sort({ created_at: -1 });

    res.json({
    success: true,
    history
    });

} catch (error) {

    res.status(500).json({
    message: "Failed to fetch history"
    });

}

});

module.exports = router;