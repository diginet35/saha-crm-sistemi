// scripts/apply-schema.js
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL, // Render’ın verdiği URL
  ssl: { rejectUnauthorized: false } // Render için gerekli
});

async function applySchema() {
  try {
    const schemaPath = path.join(__dirname, '../db/schema_pg.sql');
    const schema = fs.readFileSync(schemaPath, 'utf-8');
    await pool.query(schema);
    console.log("✅ PostgreSQL şeması başarıyla uygulandı.");
  } catch (err) {
    console.error("❌ Şema uygulanırken hata:", err);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

applySchema();
