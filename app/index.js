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
    info: {
      title: 'Cloud Lab API',
      version: '1.0.0',
      description: 'REST API deployed on AWS ECS with RDS and CloudWatch Monitoring',
    },
  },
  apis: ['./index.js'],
};
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerJsdoc(swaggerOptions)));

/**
 * @swagger
 * /health:
 *   get:
 *     summary: ALB Health Check
 *     description: Health check endpoint monitored by AWS Application Load Balancer
 *     responses:
 *       200:
 *         description: OK
 */
app.get('/health', (req, res) => res.status(200).send('OK'));

/**
 * @swagger
 * /api/simulate-error:
 *   get:
 *     summary: Trigger 500 Server Error
 *     description: Simulates an internal 500 error for testing CloudWatch 5xx Metric Alarms
 *     responses:
 *       500:
 *         description: Internal Server Error
 */
app.get('/api/simulate-error', (req, res) => {
  console.error("Manual 500 triggered for CloudWatch Alarm verification");
  res.status(500).json({ error: "Simulated 500 error for alarm verification" });
});

/**
 * @swagger
 * /api/notes:
 *   get:
 *     summary: Get all notes
 *     description: Retrieve all notes stored in PostgreSQL
 *     responses:
 *       200:
 *         description: List of notes
 */
app.get('/api/notes', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM notes ORDER BY id DESC');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * @swagger
 * /api/notes:
 *   post:
 *     summary: Create a new note
 *     description: Add a new note to the database
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - title
 *             properties:
 *               title:
 *                 type: string
 *                 example: My first cloud note
 *     responses:
 *       201:
 *         description: Note created successfully
 */
app.post('/api/notes', async (req, res) => {
  try {
    const { title } = req.body;
    if (!title) {
      return res.status(400).json({ error: "Field 'title' is required" });
    }
    const result = await pool.query(
      'INSERT INTO notes (title) VALUES ($1) RETURNING *',
      [title]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * @swagger
 * /api/notes/{id}:
 *   delete:
 *     summary: Delete a note by ID
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Note deleted successfully
 *       404:
 *         description: Note not found
 */
app.delete('/api/notes/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('DELETE FROM notes WHERE id = $1 RETURNING *', [id]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: "Note not found" });
    }
    res.json({ message: "Note deleted successfully", deleted: result.rows[0] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));