/**
 * Invoice HTTP handlers — thin layer; delegates to invoiceService.
 */

const { StatusCodes } = require('http-status-codes');

const invoiceService = require('../services/invoiceService');
const batchInvoiceService = require('../services/batchInvoiceService');
const AppError = require('../utils/AppError');
const { successResponse, paginatedResponse } = require('../utils/responseFormatter');
const { getPagination, buildPaginationMeta } = require('../utils/paginationHelper');

/**
 * GET /invoices — list with filters and pagination.
 */
async function getInvoices(req, res, next) {
  try {
    const { rollNumber, billingMonth, status } = req.query;
    const { skip, limit, page } = getPagination(req.query);

    const filters = {};
    if (rollNumber) filters.rollNumber = rollNumber;
    if (billingMonth) filters.billingMonth = billingMonth;
    if (status) filters.status = status;

    const { invoices, total, page: currentPage, limit: currentLimit } =
      await invoiceService.getAllInvoices(filters, { skip, limit, page });

    const meta = buildPaginationMeta(total, currentPage, currentLimit);

    return paginatedResponse(res, invoices, meta, 'Invoices fetched successfully');
  } catch (error) {
    next(error);
  }
}

/**
 * GET /invoices/:id — get one invoice by ID.
 */
async function getInvoice(req, res, next) {
  try {
    const invoice = await invoiceService.getInvoiceById(req.params.id);
    return successResponse(res, invoice, 'Invoice fetched successfully');
  } catch (error) {
    next(error);
  }
}

/**
 * POST /invoices/batch — generate invoices for all active students.
 * Safe to call multiple times for the same month (skips existing invoices).
 */
async function generateBatchInvoices(req, res, next) {
  try {
    const { billingMonth } = req.body;

    const result = await batchInvoiceService.generateBatchInvoices(billingMonth);

    const summary = {
      created: result.created,
      skipped: result.skipped,
      failed: result.failed,
    };

    console.log(
      `[${new Date().toISOString()}] Batch invoice generation — billingMonth: ${result.billingMonth}, created: ${summary.created}, skipped: ${summary.skipped}, failed: ${summary.failed}`
    );

    if (result.totalStudents === 0) {
      throw new AppError('No active students found', StatusCodes.BAD_REQUEST);
    }

    const statusCode =
      result.created > 0 ? StatusCodes.CREATED : StatusCodes.OK;

    const data = {
      billingMonth: result.billingMonth,
      summary,
      invoices: result.invoices,
      errors: result.errors,
    };

    return successResponse(
      res,
      data,
      'Batch invoice generation complete',
      statusCode
    );
  } catch (error) {
    next(error);
  }
}

/**
 * PUT /invoices/:id/pay — mark invoice as paid.
 */
async function markAsPaid(req, res, next) {
  try {
    const invoice = await invoiceService.markAsPaid(req.params.id);
    return successResponse(res, invoice, 'Invoice marked as paid', StatusCodes.OK);
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getInvoices,
  getInvoice,
  generateBatchInvoices,
  markAsPaid,
};
