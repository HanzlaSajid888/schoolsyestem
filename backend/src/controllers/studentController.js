/**
 * Student HTTP handlers — thin layer; delegates to studentService.
 */

const { StatusCodes } = require('http-status-codes');

const studentService = require('../services/studentService');
const { successResponse, paginatedResponse } = require('../utils/responseFormatter');
const { getPagination, buildPaginationMeta } = require('../utils/paginationHelper');

/**
 * GET /students — list with search, filters, and pagination.
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function getStudents(req, res, next) {
  try {
    const { search, grade, section, isActive } = req.query;
    const { skip, limit, page } = getPagination(req.query);

    const filters = { isActive };
    if (grade) filters.grade = grade;
    if (section) filters.section = section;

    const { students, total, page: currentPage, limit: currentLimit } =
      await studentService.getAllStudents(search, filters, { skip, limit, page });

    const meta = buildPaginationMeta(total, currentPage, currentLimit);

    return paginatedResponse(res, students, meta, 'Students fetched successfully');
  } catch (error) {
    next(error);
  }
}

/**
 * GET /students/:id — get one student by ID.
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function getStudent(req, res, next) {
  try {
    const student = await studentService.getStudentById(req.params.id);
    return successResponse(res, student, 'Student fetched successfully');
  } catch (error) {
    next(error);
  }
}

/**
 * POST /students — enroll a new student.
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function createStudent(req, res, next) {
  try {
    const student = await studentService.createStudent(req.body);
    return successResponse(
      res,
      student,
      'Student created successfully',
      StatusCodes.CREATED
    );
  } catch (error) {
    next(error);
  }
}

/**
 * PUT /students/:id — update student details.
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function updateStudent(req, res, next) {
  try {
    const student = await studentService.updateStudent(req.params.id, req.body);
    return successResponse(res, student, 'Student updated successfully');
  } catch (error) {
    next(error);
  }
}

/**
 * DELETE /students/:id — soft-delete student (isActive = false).
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
async function deleteStudent(req, res, next) {
  try {
    const student = await studentService.deleteStudent(req.params.id);
    return successResponse(res, student, 'Student deleted successfully');
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getStudents,
  getStudent,
  createStudent,
  updateStudent,
  deleteStudent,
};
