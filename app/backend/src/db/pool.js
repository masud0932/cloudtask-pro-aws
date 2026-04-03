const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, "../../.env") });

const { Pool } = require("pg");

console.log("DB debug:", {
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  passwordType: typeof process.env.DB_PASSWORD,
  passwordLoaded: process.env.DB_PASSWORD ? "yes" : "no"
});

const pool = new Pool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 5432),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: String(process.env.DB_PASSWORD || "")
  ssl: {
    require: true,
    rejectUnauthorized: false
  }
});

module.exports = pool;
