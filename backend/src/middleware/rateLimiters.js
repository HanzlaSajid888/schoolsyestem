/**
 * API rate limiters.
 */

const rateLimit = require('express-rate-limit');

const rateLimitResponse = {
  success: false,
  message: 'Too many requests, try again later',
};

/**
 * General API limit: 100 requests per 15 minutes per IP.
 */
const generalApiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    res.status(429).json(rateLimitResponse);
  },
});

/**
 * Batch invoice endpoint: 10 requests per hour per IP.
 */
const batchInvoiceLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    res.status(429).json(rateLimitResponse);
  },
});

module.exports = { generalApiLimiter, batchInvoiceLimiter };
