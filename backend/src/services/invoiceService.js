/**
 * Invoice business logic layer.
 */

const mongoose = require('mongoose');
const { StatusCodes } = require('http-status-codes');

const Invoice = require('../models/Invoice');
const AppError = require('../utils/AppError');
const { INVOICE_STATUS } = require('../config/constants');
const { generateBatchInvoices: runBatchGeneration } = require('./batchInvoiceService');
const fbrService = require('./fbrService');

/**
 * Validate MongoDB ObjectId string format.
 * @param {string} id
 * @returns {boolean}
 */
function isValidObjectId(id) {
  if (!mongoose.Types.ObjectId.isValid(id)) return false;
  return String(new mongoose.Types.ObjectId(id)) === String(id);
}

/**
 * Build MongoDB filter from invoice list filters.
 * @param {object} filters
 * @returns {object}
 */
function buildInvoiceFilter(filters = {}) {
  const filter = {};

  if (filters.rollNumber) {
    filter.rollNumber = filters.rollNumber.trim();
  }

  if (filters.billingMonth) {
    const escaped = filters.billingMonth
      .trim()
      .replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    filter.billingMonth = { $regex: escaped, $options: 'i' };
  }

  if (filters.status) {
    filter.status = filters.status;
  }

  return filter;
}

/**
 * Get paginated invoices with optional filters.
 * @param {object} [filters] - { rollNumber?, billingMonth?, status? }
 * @param {object} [pagination] - { skip, limit, page }
 * @returns {Promise<{ invoices: import('mongoose').Document[], total: number, page: number, limit: number }>}
 */
async function getAllInvoices(filters = {}, pagination = {}) {
  const { skip = 0, limit = 20, page = 1 } = pagination;
  const filter = buildInvoiceFilter(filters);

  const [invoices, total] = await Promise.all([
    Invoice.find(filter)
      .populate('studentId', 'grade avatarColor')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit),
    Invoice.countDocuments(filter),
  ]);

  return { invoices, total, page, limit };
}

/**
 * Get a single invoice by ID with populated student.
 * @param {string} id
 * @returns {Promise<import('mongoose').Document>}
 */
async function getInvoiceById(id) {
  if (!isValidObjectId(id)) {
    throw new AppError('Invalid invoice ID', StatusCodes.BAD_REQUEST);
  }

  const invoice = await Invoice.findById(id).populate(
    'studentId',
    'firstName lastName email rollNumber grade section avatarColor'
  );

  if (!invoice) {
    throw new AppError('Invoice not found', StatusCodes.NOT_FOUND);
  }

  return invoice;
}

/**
 * Mark an invoice as paid.
 * @param {string} id
 * @returns {Promise<import('mongoose').Document>}
 */
async function markAsPaid(id) {
  if (!isValidObjectId(id)) {
    throw new AppError('Invalid invoice ID', StatusCodes.BAD_REQUEST);
  }

  const invoice = await Invoice.findById(id);

  if (!invoice) {
    throw new AppError('Invoice not found', StatusCodes.NOT_FOUND);
  }

  if (invoice.status === INVOICE_STATUS.PAID) {
    throw new AppError('Invoice is already marked as paid', StatusCodes.BAD_REQUEST);
  }

  invoice.status = INVOICE_STATUS.PAID;
  
  // Call FBR Integration
  try {
    const fbrNumber = await fbrService.reportInvoiceToFBR(invoice);
    invoice.fbrInvoiceNumber = fbrNumber;
    invoice.fbrReported = true;
  } catch (err) {
    console.error('FBR Integration failed:', err);
    // Even if FBR fails, we might still want to mark it as paid, or we could rollback.
    // For now, we'll just log it.
  }

  await invoice.save();

  return invoice.populate('studentId', 'grade avatarColor');
}

/**
 * Generate pending invoices for all active students for a billing month.
 * Delegates to batchInvoiceService.
 * @param {string} billingMonth - e.g. "May 2024"
 */
async function generateBatchInvoices(billingMonth) {
  return runBatchGeneration(billingMonth);
}

module.exports = {
  getAllInvoices,
  getInvoiceById,
  markAsPaid,
  generateBatchInvoices,
};
