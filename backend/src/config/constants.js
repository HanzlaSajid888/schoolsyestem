/**
 * Application-wide constants for EduStream SMS.
 * Single source of truth for magic values — import from here; do not hardcode elsewhere.
 */

/**
 * Monthly tuition fees (PKR) by grade label.
 * Keys must match student `grade` values from the Flutter app (e.g. "Grade 9").
 * `DEFAULT` applies when the grade is unknown or not listed.
 * @type {{ "Grade 9": number, "Grade 10": number, DEFAULT: number }}
 */
const FEE_RULES = {
  'Grade 9': 5500,
  'Grade 10': 6500,
  DEFAULT: 5000,
};

/**
 * Default query pagination for list endpoints (students, invoices, etc.).
 * @type {{ DEFAULT_PAGE: number, DEFAULT_LIMIT: number, MAX_LIMIT: number }}
 */
const PAGINATION = {
  DEFAULT_PAGE: 1,
  DEFAULT_LIMIT: 20,
  MAX_LIMIT: 100,
};

/**
 * Invoice payment lifecycle values stored in MongoDB and returned by the API.
 * @type {{ PENDING: string, PAID: string }}
 */
const INVOICE_STATUS = {
  PENDING: 'pending',
  PAID: 'paid',
};

/**
 * ISO-style currency code for all fee and revenue amounts.
 * @type {string}
 */
const CURRENCY = 'PKR';

/**
 * Base path for versioned REST routes (mounted in app.js).
 * @type {string}
 */
const API_PREFIX = '/api/v1';

module.exports = {
  FEE_RULES,
  PAGINATION,
  INVOICE_STATUS,
  CURRENCY,
  API_PREFIX,
};
