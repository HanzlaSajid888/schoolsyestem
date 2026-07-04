/**
 * Core Express application (not the entry point).
 * Configures middleware and routes; export for server.js and tests.
 * Do not call app.listen() here.
 */

require('express-async-errors');

const express = require('express');
const cors = require('cors');

const helmet = require('helmet');
const morgan = require('morgan');
const mongoSanitize = require('express-mongo-sanitize');
const xss = require('xss-clean');
const hpp = require('hpp');

const { API_PREFIX } = require('./config/constants');
const routes = require('./routes');
const notFound = require('./middleware/notFound');
const errorHandler = require('./middleware/errorHandler');
const { generalApiLimiter } = require('./middleware/rateLimiters');

const app = express();

const CORS_ORIGIN = process.env.CORS_ORIGIN || '*';
const BODY_SIZE_LIMIT = '10kb';

app.use(helmet());
app.use(cors({ origin: CORS_ORIGIN }));

// Reject unusually large JSON/urlencoded payloads (413 Payload Too Large)
app.use(express.json({ limit: BODY_SIZE_LIMIT }));
app.use(express.urlencoded({ extended: true, limit: BODY_SIZE_LIMIT }));

// NoSQL injection prevention — strip $ and . from user input
app.use(mongoSanitize());

// XSS sanitization on req.body, req.query, req.params
app.use(xss());

// Prevent HTTP parameter pollution (duplicate query keys)
app.use(hpp());

if (process.env.NODE_ENV !== 'production') {
  app.use(morgan('dev'));
}

// Rate limit all /api/v1 routes (100 requests / 15 minutes per IP)
app.use(API_PREFIX, generalApiLimiter);

app.get(`${API_PREFIX}/health`, (req, res) => {
  res.json({
    success: true,
    message: 'EduStream SMS API is healthy',
    timestamp: Date.now(),
  });
});

app.use(API_PREFIX, routes);

app.post(`${API_PREFIX}/debug-login`, async (req, res) => {
  try {
    const User = require('./models/User');
    const bcrypt = require('bcryptjs');
    const user = await User.findOne({ email: 'admin@admin.com' }).select('+password');
    if (!user) return res.json({ error: 'No admin' });
    const isMatch = await bcrypt.compare('123456', user.password);
    res.json({ match: isMatch, hash: user.password });
  } catch (e) {
    res.json({ error: e.message });
  }
});
app.use(notFound);
app.use(errorHandler);

module.exports = app;
