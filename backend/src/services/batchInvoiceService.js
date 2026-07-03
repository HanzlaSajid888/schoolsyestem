/**
 * Batch invoice generation — core business logic for POST /invoices/batch.
 */

const Student = require('../models/Student');
const Invoice = require('../models/Invoice');
const { INVOICE_STATUS, CURRENCY } = require('../config/constants');
const { calculateFeeForGrade } = require('./feeCalculatorService');
const { generateInvoiceNumber } = require('../utils/invoiceNumberGenerator');

const INSERT_CHUNK_SIZE = 100;

/**
 * Insert a chunk of invoices; returns inserted docs and per-document errors.
 * @param {object[]} chunk
 * @returns {Promise<{ inserted: import('mongoose').Document[], writeErrors: object[] }>}
 */
async function insertInvoiceChunk(chunk) {
  try {
    const inserted = await Invoice.insertMany(chunk, { ordered: false });
    return { inserted, writeErrors: [] };
  } catch (err) {
    if (err.name === 'MongoBulkWriteError' || err.name === 'BulkWriteError') {
      return {
        inserted: err.insertedDocs || [],
        writeErrors: err.writeErrors || [],
      };
    }
    throw err;
  }
}

/**
 * Generate pending invoices for all active students for a billing month.
 * @param {string} billingMonth - e.g. "June 2024"
 * @returns {Promise<{
 *   billingMonth: string,
 *   totalStudents: number,
 *   created: number,
 *   skipped: number,
 *   failed: number,
 *   invoices: import('mongoose').Document[],
 *   errors: object[]
 * }>}
 */
async function generateBatchInvoices(billingMonth) {
  const trimmedMonth = billingMonth.trim();
  const year = parseInt(trimmedMonth.split(' ')[1], 10) || new Date().getFullYear();

  const students = await Student.find({ isActive: true })
    .select('_id firstName lastName rollNumber grade')
    .lean();

  let skipped = 0;
  const pending = [];

  for (const student of students) {
    const duplicate = await Invoice.checkDuplicate(student._id, trimmedMonth);

    if (duplicate) {
      skipped += 1;
      continue;
    }

    const invoiceNumber = await generateInvoiceNumber(year);
    const amount = calculateFeeForGrade(student.grade);

    pending.push({
      doc: {
        invoiceNumber,
        studentId: student._id,
        studentName: `${student.firstName} ${student.lastName}`,
        rollNumber: student.rollNumber,
        billingMonth: trimmedMonth,
        amount,
        currency: CURRENCY,
        status: INVOICE_STATUS.PENDING,
      },
      student,
    });
  }

  const chunks = [];
  for (let i = 0; i < pending.length; i += INSERT_CHUNK_SIZE) {
    chunks.push(pending.slice(i, i + INSERT_CHUNK_SIZE));
  }

  const settled = await Promise.allSettled(
    chunks.map((chunk) => insertInvoiceChunk(chunk.map((item) => item.doc)))
  );

  const invoices = [];
  const errors = [];
  let failed = 0;

  settled.forEach((result, chunkIndex) => {
    const chunkItems = chunks[chunkIndex];

    if (result.status === 'fulfilled') {
      const { inserted, writeErrors } = result.value;
      invoices.push(...inserted);

      writeErrors.forEach((writeError) => {
        failed += 1;
        const item = chunkItems[writeError.index];
        errors.push({
          studentId: item?.student._id,
          rollNumber: item?.student.rollNumber,
          studentName: item
            ? `${item.student.firstName} ${item.student.lastName}`
            : undefined,
          message: writeError.errmsg || writeError.message || 'Insert failed',
        });
      });
    } else {
      failed += chunkItems.length;
      chunkItems.forEach((item) => {
        errors.push({
          studentId: item.student._id,
          rollNumber: item.student.rollNumber,
          studentName: `${item.student.firstName} ${item.student.lastName}`,
          message: result.reason?.message || 'Batch insert failed',
        });
      });
    }
  });

  return {
    billingMonth: trimmedMonth,
    totalStudents: students.length,
    created: invoices.length,
    skipped,
    failed,
    invoices,
    errors,
  };
}

module.exports = { generateBatchInvoices };
