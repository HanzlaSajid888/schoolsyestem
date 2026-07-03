/**
 * Global Express error handler (4-argument middleware).
 * Must be registered last in app.js after all routes and notFound.
 *
 * All error responses use Flutter-compatible shape:
 * { success: false, message: string, errors: [{ field, message }] | null }
 */

const { StatusCodes } = require('http-status-codes');

/**
 * @typedef {{ field: string, message: string }} FieldError
 */

/**
 * @param {import('express').Response} res
 * @param {number} statusCode
 * @param {string} message
 * @param {FieldError[]|null} [errors]
 */
function sendError(res, statusCode, message, errors = null) {
  res.status(statusCode).json({
    success: false,
    message,
    errors,
  });
}

/**
 * @param {string} field
 * @returns {string}
 */
function humanizeFieldLabel(field) {
  return field
    .replace(/([A-Z])/g, ' $1')
    .trim()
    .split(/\s+/)
    .map((word, index) => {
      const lower = word.toLowerCase();
      return index === 0
        ? lower.charAt(0).toUpperCase() + lower.slice(1)
        : lower;
    })
    .join(' ');
}

/**
 * @param {import('joi').ValidationErrorItem} detail
 * @returns {FieldError}
 */
function mapJoiDetail(detail) {
  const field = detail.path.join('.') || 'body';
  const label = humanizeFieldLabel(field);
  let message = detail.message.replace(/"/g, '');

  if (message.startsWith(field)) {
    message = label + message.slice(field.length);
  } else if (message.includes(field)) {
    message = message.replace(field, label);
  }

  return { field, message };
}

/**
 * @param {import('joi').ValidationError} err
 * @returns {FieldError[]}
 */
function mapJoiErrors(err) {
  return err.details.map(mapJoiDetail);
}

/**
 * @param {import('mongoose').Error.ValidationError} err
 * @returns {FieldError[]}
 */
function mapMongooseValidationErrors(err) {
  return Object.values(err.errors).map((error) => ({
    field: error.path,
    message: error.message,
  }));
}

/**
 * @param {Error & { keyValue?: Record<string, unknown> }} err
 * @returns {string}
 */
function getDuplicateSummaryMessage(err) {
  const keyValue = err.keyValue || {};
  const fields = Object.keys(keyValue);

  if (fields.includes('rollNumber')) {
    return 'A student with this roll number already exists';
  }

  if (fields.includes('email')) {
    return 'A student with this email already exists';
  }

  if (fields.includes('invoiceNumber')) {
    return 'An invoice with this invoice number already exists';
  }

  if (fields.includes('studentId') && fields.includes('billingMonth')) {
    return 'An invoice for this student and billing month already exists';
  }

  if (fields.includes('name')) {
    return 'A record with this name already exists';
  }

  return 'Duplicate record already exists';
}

/**
 * @param {Error & { keyValue?: Record<string, unknown> }} err
 * @returns {FieldError[]}
 */
function mapDuplicateKeyErrors(err) {
  const keyValue = err.keyValue || {};

  return Object.entries(keyValue).map(([field, value]) => ({
    field,
    message: `${field} "${value}" already exists`,
  }));
}

/**
 * @param {FieldError[]|string[]|null} errors
 * @returns {FieldError[]|null}
 */
function normalizeErrors(errors) {
  if (!errors) return null;

  return errors.map((entry, index) => {
    if (typeof entry === 'string') {
      return { field: 'general', message: entry };
    }
    return entry;
  });
}

function errorHandler(err, req, res, next) {
  const isDevelopment = process.env.NODE_ENV !== 'production';

  if (isDevelopment) {
    console.error('Error:', err);
  } else {
    console.error(err.message);
  }

  // Joi validation
  if (err.isJoi) {
    const errors = mapJoiErrors(err);
    return sendError(
      res,
      StatusCodes.UNPROCESSABLE_ENTITY,
      'Validation failed',
      errors
    );
  }

  // Operational errors with optional field errors (AppError, etc.)
  if (err.statusCode) {
    return sendError(
      res,
      err.statusCode,
      err.message,
      normalizeErrors(err.errors || null)
    );
  }

  // Mongoose schema validation
  if (err.name === 'ValidationError') {
    const errors = mapMongooseValidationErrors(err);
    return sendError(
      res,
      StatusCodes.UNPROCESSABLE_ENTITY,
      'Validation failed',
      errors
    );
  }

  // Mongoose duplicate key
  if (err.code === 11000) {
    return sendError(
      res,
      StatusCodes.CONFLICT,
      getDuplicateSummaryMessage(err),
      mapDuplicateKeyErrors(err)
    );
  }

  // Payload too large
  if (err.type === 'entity.too.large') {
    return sendError(
      res,
      StatusCodes.REQUEST_TOO_LONG,
      'Request payload too large',
      null
    );
  }

  // Invalid ObjectId (CastError)
  if (err.name === 'CastError') {
    return sendError(res, StatusCodes.NOT_FOUND, 'Resource not found', null);
  }

  // Default server error
  const statusCode = err.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
  const message =
    statusCode === StatusCodes.INTERNAL_SERVER_ERROR
      ? 'Internal server error'
      : err.message || 'Internal server error';

  return sendError(res, statusCode, message, null);
}

module.exports = errorHandler;
