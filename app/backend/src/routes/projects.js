const express = require("express");
const pool = require("../db/pool");

const router = express.Router();

router.get("/", async (req, res, next) => {
  try {
    const result = await pool.query(`
      SELECT id, name, description, created_at
      FROM projects
      ORDER BY id ASC
    `);

    res.json(result.rows);
  } catch (error) {
    next(error);
  }
});

router.post("/", async (req, res, next) => {
  try {
    const { name, description } = req.body;

    if (!name) {
      return res.status(400).json({ message: "Project name is required" });
    }

    const result = await pool.query(
      `
      INSERT INTO projects (name, description)
      VALUES ($1, $2)
      RETURNING *
      `,
      [name, description || null]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    next(error);
  }
});

module.exports = router;
