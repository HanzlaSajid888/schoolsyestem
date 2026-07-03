/**
 * @file Invoice Mongoose model.
 * Stores fee billing per student per month; status pending | paid.
 * Denormalized studentName/rollNumber for fast list queries and filtering.
 */

const mongoose = require('mongoose');
const { INVOICE_STATUS, CURRENCY } = require('../config/constants');

const MONTH_NAMES = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/**
 * Parse billing month label (e.g. "May 2024") to a Date for sorting.
 * @param {string} billingMonth
 * @returns {Date}
 */
function parseBillingMonth(billingMonth) {
  const [name, yearStr] = billingMonth.trim().split(' ');
  const monthIndex = MONTH_NAMES.indexOf(name);
  const year = Number(yearStr);

  if (monthIndex === -1 || Number.isNaN(year)) {
    return new Date(0);
  }

  return new Date(year, monthIndex, 1);
}

/**
 * @typedef {object} InvoiceFilters
 * @property {string} [rollNumber]
 * @property {string} [billingMonth]
 * @property {string} [status]
 */

/**
 * @typedef {object} PaginationOptions
 * @property {number} [skip]
 * @property {number} [limit]
 * @property {number} [page]
 */

/**
 * @typedef {object} PaginatedInvoices
 * @property {import('mongoose').Document[]} data
 * @property {number} total
 * @property {number} page
 * @property {number} limit
 */

/**
 * @typedef {object} InvoiceSummaryStats
 * @property {number} totalRevenue
 * @property {number} pendingCount
 * @property {number} paidCount
 */

/**
 * @typedef {object} MonthlyRevenueTrendItem
 * @property {string} month
 * @property {number} revenue
 * @property {number} count
 */

const invoiceSchema = new mongoose.Schema(
  {
    invoiceNumber: {
      type: String,
      required: [true, 'Invoice number is required'],
      unique: true,
      trim: true,
    },
    studentId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Student',
      required: [true, 'Student is required'],
      index: true,
    },
    studentName: {
      type: String,
      required: [true, 'Student name is required'],
      trim: true,
    },
    rollNumber: {
      type: String,
      required: [true, 'Roll number is required'],
      trim: true,
    },
    billingMonth: {
      type: String,
      required: [true, 'Billing month is required'],
      trim: true,
    },
    amount: {
      type: Number,
      required: [true, 'Amount is required'],
      min: [0, 'Amount cannot be negative'],
    },
    currency: {
      type: String,
      default: CURRENCY,
    },
    status: {
      type: String,
      enum: {
        values: [INVOICE_STATUS.PENDING, INVOICE_STATUS.PAID],
        message: 'Status must be pending or paid',
      },
      default: INVOICE_STATUS.PENDING,
    },
    paidAt: {
      type: Date,
      default: null,
    },
    fbrInvoiceNumber: {
      type: String,
      default: null,
    },
    fbrReported: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
    toJSON: {
      virtuals: true,
      versionKey: false,
      transform(doc, ret) {
        ret.id = ret._id;
        delete ret._id;
        return ret;
      },
    },
  }
);

/**
 * Sync paidAt when status changes on save.
 */
invoiceSchema.pre('save', function (next) {
  if (!this.isModified('status')) {
    return next();
  }

  if (this.status === INVOICE_STATUS.PAID) {
    this.paidAt = new Date();
  } else if (this.status === INVOICE_STATUS.PENDING) {
    this.paidAt = null;
  }

  next();
});

/**
 * List invoices with optional filters and pagination.
 * @param {InvoiceFilters} [filters]
 * @param {PaginationOptions} [pagination]
 * @returns {Promise<PaginatedInvoices>}
 */
invoiceSchema.statics.getByFilters = async function (filters = {}, pagination = {}) {
  const { skip = 0, limit = 20, page = 1 } = pagination;
  const filter = {};

  if (filters.rollNumber) {
    filter.rollNumber = filters.rollNumber.trim();
  }

  if (filters.billingMonth) {
    filter.billingMonth = filters.billingMonth.trim();
  }

  if (filters.status) {
    filter.status = filters.status;
  }

  const [data, total] = await Promise.all([
    this.find(filter).sort({ createdAt: -1 }).skip(skip).limit(limit),
    this.countDocuments(filter),
  ]);

  return { data, total, page, limit };
};

/**
 * Dashboard aggregate stats: revenue from paid invoices and status counts.
 * @returns {Promise<InvoiceSummaryStats>}
 */
invoiceSchema.statics.getSummaryStats = async function () {
  const [result] = await this.aggregate([
    {
      $group: {
        _id: null,
        totalRevenue: {
          $sum: {
            $cond: [{ $eq: ['$status', INVOICE_STATUS.PAID] }, '$amount', 0],
          },
        },
        pendingCount: {
          $sum: {
            $cond: [{ $eq: ['$status', INVOICE_STATUS.PENDING] }, 1, 0],
          },
        },
        paidCount: {
          $sum: {
            $cond: [{ $eq: ['$status', INVOICE_STATUS.PAID] }, 1, 0],
          },
        },
      },
    },
  ]);

  return {
    totalRevenue: result?.totalRevenue ?? 0,
    pendingCount: result?.pendingCount ?? 0,
    paidCount: result?.paidCount ?? 0,
  };
};

/**
 * Check for an existing invoice for the same student and billing month.
 * @param {import('mongoose').Types.ObjectId|string} studentId
 * @param {string} billingMonth
 * @returns {Promise<import('mongoose').Document|null>}
 */
invoiceSchema.statics.checkDuplicate = async function (studentId, billingMonth) {
  return this.findOne({
    studentId,
    billingMonth: billingMonth.trim(),
  });
};

/**
 * Last N months of invoice revenue grouped by billingMonth (chronological).
 * @param {number} [months=6]
 * @returns {Promise<MonthlyRevenueTrendItem[]>}
 */
invoiceSchema.statics.getMonthlyRevenueTrend = async function (months = 6) {
  const grouped = await this.aggregate([
    {
      $group: {
        _id: '$billingMonth',
        totalExpected: { $sum: '$amount' },
        paidAmount: {
          $sum: {
            $cond: [{ $eq: ['$status', INVOICE_STATUS.PAID] }, '$amount', 0],
          },
        },
        pendingAmount: {
          $sum: {
            $cond: [{ $eq: ['$status', INVOICE_STATUS.PENDING] }, '$amount', 0],
          },
        },
        count: { $sum: 1 },
      },
    },
  ]);

  const trend = grouped
    .map((row) => ({
      month: row._id,
      totalExpected: row.totalExpected,
      paidAmount: row.paidAmount,
      pendingAmount: row.pendingAmount,
      count: row.count,
    }))
    .sort((a, b) => parseBillingMonth(a.month) - parseBillingMonth(b.month));

  if (months > 0 && trend.length > months) {
    return trend.slice(-months);
  }

  return trend;
};

invoiceSchema.index({ studentId: 1, billingMonth: 1 }, { unique: true });
invoiceSchema.index({ status: 1 });
invoiceSchema.index({ rollNumber: 1 });
invoiceSchema.index({ billingMonth: 1 });

/** @type {import('mongoose').Model} */
const Invoice = mongoose.model('Invoice', invoiceSchema);

module.exports = Invoice;
