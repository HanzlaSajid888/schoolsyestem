/**
 * Generates unique invoice numbers (INV-YYYY-NNN).
 * Uses an atomic counter per year for safe concurrent batch generation.
 */

const mongoose = require('mongoose');
const Invoice = require('../models/Invoice');

const counterSchema = new mongoose.Schema({
  _id: { type: String, required: true },
  seq: { type: Number, default: 0 },
});

const Counter =
  mongoose.models.InvoiceCounter ||
  mongoose.model('InvoiceCounter', counterSchema);

/**
 * Format sequence as INV-YYYY-NNN.
 * @param {number} year
 * @param {number} sequence
 * @returns {string}
 */
function formatInvoiceNumber(year, sequence) {
  return `INV-${year}-${String(sequence).padStart(3, '0')}`;
}

/**
 * Initialize counter from existing invoices when first used for a year.
 * @param {string} key - Counter document id
 * @param {number} year
 */
async function initializeCounterFromInvoices(key, year) {
  const prefix = `INV-${year}-`;
  const existingCount = await Invoice.countDocuments({
    invoiceNumber: { $regex: `^${prefix}` },
  });

  if (existingCount === 0) return;

  try {
    await Counter.create({ _id: key, seq: existingCount });
  } catch (err) {
    if (err.code !== 11000) throw err;
  }
}

/**
 * Generate the next invoice number for a calendar year.
 * Counts existing invoices on first use, then atomically increments.
 * @param {number} [year] - Defaults to current year
 * @returns {Promise<string>} e.g. "INV-2024-001"
 */
async function generateInvoiceNumber(year = new Date().getFullYear()) {
  const key = `invoice-${year}`;

  const existing = await Counter.findById(key);
  if (!existing) {
    await initializeCounterFromInvoices(key, year);
  }

  const counter = await Counter.findOneAndUpdate(
    { _id: key },
    { $inc: { seq: 1 } },
    { new: true, upsert: true }
  );

  return formatInvoiceNumber(year, counter.seq);
}

module.exports = { generateInvoiceNumber };
