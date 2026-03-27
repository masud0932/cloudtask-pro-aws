const express = require("express");

const router = express.Router();

router.post("/login", async (req, res) => {
  const { email } = req.body;

  res.json({
    message: "Login successful (demo mode)",
    user: {
      id: 1,
      email: email || "demo@cloudtaskpro.com",
      full_name: "Demo User"
    },
    token: "demo-jwt-token"
  });
});

module.exports = router;
