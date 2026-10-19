const express = require('express');
const { Pool } = require('pg');
const swaggerUi = require('swagger-ui-express');
const swaggerJsdoc = require('swagger-jsdoc');

const app = express();
app.use(express.json());

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

pool.query(`
  CREATE TABLE IF NOT EXISTS notes (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
  )
`).catch(err => console.error("DB Init Error:", err));

const swaggerOptions = {
  swaggerDefinition: {
    openapi: '3.0.0',
    info: { title: 'Cloud Lab API', version: '1.0.0' },
  },
  apis: ['./index.js'],
};
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerJsdoc(swaggerOptions)));

/**
 * @swagger
 * /health:
 *   get:
 *     description: Health Check for AWS ALB
 *     responses:
 *       200:
 *         description: OK
 */
app.get('/health', (req, res) => res.status(200).send('OK'));

/**
 * @swagger
 * /api/notes:
 *   get:
 *     description: Get all notes from db
 *     responses:
 *       200:
 *         description: List of notes
 */
app.get('/api/notes', async (req, res) => {
    try {
      const result = await pool.query('SELECT * FROM notes');
      res.json(result.rows);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

/**
 * @swagger
 * /api/notes:
 *   post:
 *     description: Create a new note
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title: { type: string }
 *     responses:
 *       201:
 *         description: Created
 */
app.post('/api/notes', async (req, res) => {
    try {
      const { title } = req.body;
      const result = await pool.query('INSERT INTO notes (title) VALUES ($1) RETURNING *', [title]);
      res.status(201).json(result.rows[0]);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));