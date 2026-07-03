/**
 * Dashboard HTTP handlers.
 */

const dashboardService = require('../services/dashboardService');
const { successResponse } = require('../utils/responseFormatter');

/**
 * GET /dashboard/summary — aggregate metrics for the Flutter dashboard.
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function getSummary(req, res, next) {
  try {
    const summary = await dashboardService.getSummary();

    return successResponse(res, summary, 'Dashboard summary fetched successfully');
  } catch (error) {
    next(error);
  }
}

async function getTrends(req, res, next) {
  try {
    const limit = parseInt(req.query.months, 10) || 6;
    const trends = await dashboardService.getTrends(limit);
    return successResponse(res, trends, 'Dashboard trends fetched successfully');
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getSummary,
  getTrends,
};
