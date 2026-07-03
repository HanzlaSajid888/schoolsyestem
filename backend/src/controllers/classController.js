/**
 * Class (grade) HTTP handlers.
 */

const { StatusCodes } = require('http-status-codes');

const Class = require('../models/Class');
const { successResponse } = require('../utils/responseFormatter');

/**
 * GET /classes — list all classes alphabetically.
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function getClasses(req, res, next) {
  try {
    const classes = await Class.find().sort({ name: 1 });
    return successResponse(res, classes, 'Classes fetched successfully');
  } catch (error) {
    next(error);
  }
}

/**
 * POST /classes — create or return existing class by name.
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function createClass(req, res, next) {
  try {
    const { name } = req.body;
    const { doc, created } = await Class.findOrCreate(name);

    if (created) {
      return successResponse(res, doc, 'Class created', StatusCodes.CREATED);
    }

    return successResponse(res, doc, 'Class already exists', StatusCodes.OK);
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getClasses,
  createClass,
};
