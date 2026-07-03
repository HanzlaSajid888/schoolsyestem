/**
 * Validates req.params.id as a MongoDB ObjectId before route handlers run.
 */

const mongoose = require('mongoose');
const { StatusCodes } = require('http-status-codes');

/**
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
function validateObjectId(req, res, next) {
  const { id } = req.params;

  if (!mongoose.isValidObjectId(id)) {
    return res.status(StatusCodes.NOT_FOUND).json({
      success: false,
      message: 'Resource not found',
      errors: null,
    });
  }

  next();
}

module.exports = validateObjectId;
