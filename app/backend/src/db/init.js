const pool = require("./pool");

async function initDb() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      email VARCHAR(255) UNIQUE NOT NULL,
      password VARCHAR(255) NOT NULL,
      full_name VARCHAR(255) NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS projects (
      id SERIAL PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      description TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `);

  await pool.query(`
    CREATE TABLE IF NOT EXISTS tasks (
      id SERIAL PRIMARY KEY,
      title VARCHAR(255) NOT NULL,
      description TEXT,
      status VARCHAR(50) NOT NULL DEFAULT 'todo',
      priority VARCHAR(50) NOT NULL DEFAULT 'medium',
      project_id INTEGER REFERENCES projects(id) ON DELETE SET NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `);

  const projectCount = await pool.query("SELECT COUNT(*)::int AS count FROM projects");
  if (projectCount.rows[0].count === 0) {
    await pool.query(`
      INSERT INTO projects (name, description)
      VALUES
        ('Platform Migration', 'Move core services to AWS'),
        ('Security Hardening', 'Improve IAM, patching, and observability');
    `);
  }

  const taskCount = await pool.query("SELECT COUNT(*)::int AS count FROM tasks");
  if (taskCount.rows[0].count === 0) {
    await pool.query(`
      INSERT INTO tasks (title, description, status, priority, project_id)
      VALUES
        ('Create VPC', 'Set up public and private subnets', 'done', 'high', 1),
        ('Deploy ALB', 'Configure Application Load Balancer', 'in-progress', 'high', 1),
        ('Enable CloudWatch Alarms', 'Set alarms for EC2 and RDS', 'todo', 'medium', 2);
    `);
  }
}

module.exports = initDb;
