/**
 * 404 handler for unmatched routes.
 * Registered after all route definitions, before errorHandler.
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */

const { StatusCodes } = require('http-status-codes');

function notFound(req, res, next) {
  const path = req.originalUrl || req.url;

  res.status(StatusCodes.NOT_FOUND).json({
    success: false,
    message: `Route ${path} not found`,
    errors: null,
  });
}

module.exports = notFound;
