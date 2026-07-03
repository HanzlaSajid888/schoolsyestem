/**
 * Dashboard routes — mount at /api/v1/dashboard
 *
 * PERFORMANCE: On large datasets, /summary should use Redis caching (5-minute TTL).
 * For v1, direct MongoDB aggregation queries are sufficient.
 */

const express = require('express');
const { StatusCodes } = require('http-status-codes');

const dashboardController = require('../controllers/dashboardController');

const router = express.Router();

// Dashboard summary metrics (students, revenue, pending fees)
router.get('/summary', dashboardController.getSummary);

router.get('/trends', dashboardController.getTrends);

module.exports = router;
