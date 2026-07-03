/**
 * Invoice routes — mount at /api/v1/invoices
 *
 * ROUTE ORDER MATTERS:
 * POST /batch must be defined BEFORE GET /:id.
 * Otherwise Express treats "batch" as an :id parameter.
 */

const express = require('express');

const invoiceController = require('../controllers/invoiceController');
const validate = require('../middleware/validate');
const validateObjectId = require('../middleware/validateObjectId');
const { batchInvoiceLimiter } = require('../middleware/rateLimiters');
const {
  invoiceQuerySchema,
  batchInvoiceSchema,
} = require('../validators/invoiceValidator');

const router = express.Router();

// List invoices with optional filters
router.get(
  '/',
  validate(invoiceQuerySchema, 'query'),
  invoiceController.getInvoices
);

// Batch-generate invoices for a billing month (must be before /:id)
// Stricter rate limit: 10 requests / hour per IP
router.post(
  '/batch',
  batchInvoiceLimiter,
  validate(batchInvoiceSchema),
  invoiceController.generateBatchInvoices
);

// Get a single invoice by ID
router.get('/:id', validateObjectId, invoiceController.getInvoice);

// Mark invoice as paid
router.put('/:id/pay', validateObjectId, invoiceController.markAsPaid);

module.exports = router;
