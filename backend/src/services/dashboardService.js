/**
 * Dashboard aggregation logic for GET /api/v1/dashboard/summary.
 */

const Student = require('../models/Student');
const Invoice = require('../models/Invoice');
const { INVOICE_STATUS, CURRENCY } = require('../config/constants');

/**
 * Extract sum total from a MongoDB aggregation result.
 * @param {object[]} result
 * @returns {number}
 */
function extractAggregateTotal(result) {
  return result[0]?.total ?? 0;
}

/**
 * Dashboard summary metrics (parallel queries).
 * @returns {Promise<{
 *   totalStudents: number,
 *   totalRevenue: number,
 *   pendingInvoicesCount: number,
 *   totalPendingAmount: number,
 *   currency: string,
 *   recentInvoices: import('mongoose').Document[]
 * }>}
 */
async function getSummary() {
  const [
    totalStudents,
    revenueResult,
    pendingInvoicesCount,
    pendingAmountResult,
    recentInvoices,
  ] = await Promise.all([
    Student.countDocuments({ isActive: true }),

    Invoice.aggregate([
      { $match: { status: INVOICE_STATUS.PAID } },
      { $group: { _id: null, total: { $sum: '$amount' } } },
    ]),

    Invoice.countDocuments({ status: INVOICE_STATUS.PENDING }),

    Invoice.aggregate([
      { $match: { status: INVOICE_STATUS.PENDING } },
      { $group: { _id: null, total: { $sum: '$amount' } } },
    ]),

    Invoice.find({ status: INVOICE_STATUS.PAID })
      .sort({ paidAt: -1 })
      .limit(5)
      .populate('studentId', 'firstName lastName'),
  ]);

  return {
    totalStudents,
    totalRevenue: extractAggregateTotal(revenueResult),
    pendingInvoicesCount,
    totalPendingAmount: extractAggregateTotal(pendingAmountResult),
    currency: CURRENCY,
    recentInvoices,
  };
}

/**
 * Get revenue trends for the last N months.
 */
async function getTrends(limit = 6) {
  return await Invoice.getMonthlyRevenueTrend(limit);
}

module.exports = { getSummary, getTrends };
