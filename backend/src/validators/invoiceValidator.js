/**
 * Joi validation schemas for Invoice routes.
 */

const Joi = require('joi');
const { INVOICE_STATUS } = require('../config/constants');

const BILLING_MONTH_PATTERN =
  /^(January|February|March|April|May|June|July|August|September|October|November|December) \d{4}$/;

/**
 * GET /invoices — list query parameters.
 */
const invoiceQuerySchema = Joi.object({
  rollNumber: Joi.string().trim().optional().allow(''),
  billingMonth: Joi.string().trim().optional().allow(''),
  status: Joi.string()
    .valid(INVOICE_STATUS.PENDING, INVOICE_STATUS.PAID)
    .optional(),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20),
});

/**
 * POST /invoices/batch — generate invoices for a billing month.
 */
const batchInvoiceSchema = Joi.object({
  billingMonth: Joi.string()
    .trim()
    .required()
    .pattern(BILLING_MONTH_PATTERN)
    .messages({
      'string.pattern.base': 'Billing month must match format "May 2024"',
      'any.required': 'Billing month is required',
    }),
});

module.exports = {
  invoiceQuerySchema,
  batchInvoiceSchema,
};
