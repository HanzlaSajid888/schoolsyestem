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

app.get(`${API_PREFIX}/env-test`, (req, res) => {
  res.json({
    uri_present: !!process.env.MONGODB_URI,
    uri_start: process.env.MONGODB_URI ? process.env.MONGODB_URI.substring(0, 25) : null,
    jwt_present: !!process.env.JWT_SECRET,
    vercel: process.env.VERCEL
  });
});

app.get(`${API_PREFIX}/db-status`, async (req, res) => {
  const mongoose = require('mongoose');
  let uri = process.env.MONGODB_URI;
  try {
    if (mongoose.connection.readyState !== 1) {
      await mongoose.connect(uri, { serverSelectionTimeoutMS: 3000 });
    }
    const User = require('./models/User'); // fixed path
    const count = await User.countDocuments();
    res.json({ status: 'Connected successfully!', count });
  } catch(e) {
    res.json({ status: 'Error', error: e.message, stack: e.stack });
  }
});

app.use(API_PREFIX, routes);

app.post(`${API_PREFIX}/login-test`, async (req, res) => {
  try {
    const User = require('./models/User');
    const { email, password } = req.body;
    const user = await User.findOne({ email }).select('+password');
    if (!user) return res.json({ error: 'User not found' });
    
    const isMatch = await user.matchPassword(password);
    if (!isMatch) return res.json({ error: 'Wrong password', hash: user.password });
    
    const jwt = require('jsonwebtoken');
    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET || 'secret123', { expiresIn: '30d' });
    
    res.json({ status: 'Success', token });
  } catch (e) {
    res.json({ error_caught: e.message, stack: e.stack });
  }
});

module.exports = app;
