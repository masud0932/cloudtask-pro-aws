const express = require("express");
const pool = require("../db/pool");

const router = express.Router();

router.get("/", async (req, res, next) => {
  try {
    const result = await pool.query(`
      SELECT
        t.id,
        t.title,
        t.description,
        t.status,
        t.priority,
        t.project_id,
        p.name AS project_name,
        t.created_at
      FROM tasks t
      LEFT JOIN projects p ON t.project_id = p.id
      ORDER BY t.id ASC
    `);

    res.json(result.rows);
  } catch (error) {
    next(error);
  }
});

router.post("/", async (req, res, next) => {
  try {
    const { title, description, status, priority, project_id } = req.body;

    if (!title) {
      return res.status(400).json({ message: "Task title is required" });
    }

    const result = await pool.query(
      `
      INSERT INTO tasks (title, description, status, priority, project_id)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
      `,
      [
        title,
        description || null,
        status || "todo",
        priority || "medium",
        project_id || null
      ]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    next(error);
  }
});

router.put("/:id", async (req, res, next) => {
  try {
    const { id } = req.params;
    const { title, description, status, priority, project_id } = req.body;

    const result = await pool.query(
      `
      UPDATE tasks
      SET
        title = $1,
        description = $2,
        status = $3,
        priority = $4,
        project_id = $5
      WHERE id = $6
      RETURNING *
      `,
      [title, description, status, priority, project_id, id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ message: "Task not found" });
    }

    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
});

router.delete("/:id", async (req, res, next) => {
  try {
    const result = await pool.query(
      "DELETE FROM tasks WHERE id = $1 RETURNING id",
      [req.params.id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ message: "Task not found" });
    }

    res.json({ message: "Task deleted successfully" });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
