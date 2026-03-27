const express = require("express");
const router = express.Router();
const pool = require("../db/pool");

router.get("/", async (req, res, next) => {
  try {
    const totalTasksResult = await pool.query(
      "SELECT COUNT(*)::int AS count FROM tasks"
    );

    const todoTasksResult = await pool.query(
      "SELECT COUNT(*)::int AS count FROM tasks WHERE status = 'todo'"
    );

    const inProgressTasksResult = await pool.query(
      "SELECT COUNT(*)::int AS count FROM tasks WHERE status = 'in-progress'"
    );

    const doneTasksResult = await pool.query(
      "SELECT COUNT(*)::int AS count FROM tasks WHERE status = 'done'"
    );

    const totalProjectsResult = await pool.query(
      "SELECT COUNT(*)::int AS count FROM projects"
    );

    res.json({
      tasks: {
        total: totalTasksResult.rows[0].count,
        todo: todoTasksResult.rows[0].count,
        in_progress: inProgressTasksResult.rows[0].count,
        done: doneTasksResult.rows[0].count
      },
      projects: {
        total: totalProjectsResult.rows[0].count
      }
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
