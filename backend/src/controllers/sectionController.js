/**
 * Section HTTP handlers.
 */

const { StatusCodes } = require('http-status-codes');

const Section = require('../models/Section');
const { successResponse } = require('../utils/responseFormatter');

/**
 * GET /sections — list all sections alphabetically.
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function getSections(req, res, next) {
  try {
    const sections = await Section.find().sort({ name: 1 });
    return successResponse(res, sections, 'Sections fetched successfully');
  } catch (error) {
    next(error);
  }
}

/**
 * POST /sections — create or return existing section by name.
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function createSection(req, res, next) {
  try {
    const { name } = req.body;
    const { doc, created } = await Section.findOrCreate(name);

    if (created) {
      return successResponse(res, doc, 'Section created', StatusCodes.CREATED);
    }

    return successResponse(res, doc, 'Section already exists', StatusCodes.OK);
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getSections,
  createSection,
};
