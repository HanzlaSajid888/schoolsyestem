/**
 * Student business logic layer.
 */

const mongoose = require('mongoose');
const { StatusCodes } = require('http-status-codes');

const Student = require('../models/Student');
const Invoice = require('../models/Invoice');
const AppError = require('../utils/AppError');
const { INVOICE_STATUS } = require('../config/constants');

/**
 * Validate MongoDB ObjectId string format.
 * @param {string} id
 * @returns {boolean}
 */
function isValidObjectId(id) {
  if (!mongoose.Types.ObjectId.isValid(id)) return false;
  return String(new mongoose.Types.ObjectId(id)) === String(id);
}

/**
 * Check if email is already used by another student.
 * @param {string} email
 * @param {string} [excludeId]
 * @returns {Promise<boolean>}
 */
async function existsByEmail(email, excludeId) {
  const filter = { email: email.toLowerCase().trim() };
  if (excludeId) {
    filter._id = { $ne: excludeId };
  }
  const count = await Student.countDocuments(filter);
  return count > 0;
}

/**
 * Get paginated students with search and filters.
 * @param {string} [query] - Search term
 * @param {object} [filters] - { grade?, section?, isActive? }
 * @param {object} [pagination] - { skip, limit, page }
 * @returns {Promise<{ students: import('mongoose').Document[], total: number, page: number, limit: number }>}
 */
async function getAllStudents(query, filters = {}, pagination = {}) {
  const { data, total, page, limit } = await Student.findBySearch(
    query,
    filters,
    pagination
  );

  return { students: data, total, page, limit };
}

/**
 * Get a single student by ID.
 * @param {string} id
 * @returns {Promise<import('mongoose').Document>}
 */
async function getStudentById(id) {
  if (!isValidObjectId(id)) {
    throw new AppError('Invalid student ID', StatusCodes.BAD_REQUEST);
  }

  const student = await Student.findById(id);

  if (!student) {
    throw new AppError('Student not found', StatusCodes.NOT_FOUND);
  }

  return student;
}

/**
 * Create a new student.
 * @param {object} data
 * @returns {Promise<import('mongoose').Document>}
 */
async function createStudent(data) {
  const rollExists = await Student.existsByRollNumber(data.rollNumber);
  if (rollExists) {
    throw new AppError('Roll number already exists', StatusCodes.CONFLICT);
  }

  const emailExists = await existsByEmail(data.email);
  if (emailExists) {
    throw new AppError('Email already exists', StatusCodes.CONFLICT);
  }

  const student = await Student.create(data);
  return student;
}

/**
 * Update an existing student.
 * @param {string} id
 * @param {object} data
 * @returns {Promise<import('mongoose').Document>}
 */
async function updateStudent(id, data) {
  if (!isValidObjectId(id)) {
    throw new AppError('Invalid student ID', StatusCodes.BAD_REQUEST);
  }

  const student = await Student.findById(id);

  if (!student) {
    throw new AppError('Student not found', StatusCodes.NOT_FOUND);
  }

  if (data.rollNumber) {
    const rollExists = await Student.existsByRollNumber(data.rollNumber, id);
    if (rollExists) {
      throw new AppError('Roll number already exists', StatusCodes.CONFLICT);
    }
  }

  if (data.email) {
    const emailExists = await existsByEmail(data.email, id);
    if (emailExists) {
      throw new AppError('Email already exists', StatusCodes.CONFLICT);
    }
  }

  Object.assign(student, data);
  await student.save();

  return student;
}

/**
 * Soft-delete a student (sets isActive to false).
 * @param {string} id
 * @returns {Promise<import('mongoose').Document>}
 */
async function deleteStudent(id) {
  if (!isValidObjectId(id)) {
    throw new AppError('Invalid student ID', StatusCodes.BAD_REQUEST);
  }

  const student = await Student.findById(id);

  if (!student) {
    throw new AppError('Student not found', StatusCodes.NOT_FOUND);
  }

  const pendingCount = await Invoice.countDocuments({
    studentId: id,
    status: INVOICE_STATUS.PENDING,
  });

  if (pendingCount > 0) {
    throw new AppError(
      'Cannot delete student with pending invoices. Mark invoices as paid or resolve them first.',
      StatusCodes.BAD_REQUEST
    );
  }

  student.isActive = false;
  await student.save();

  return student;
}

module.exports = {
  getAllStudents,
  getStudentById,
  createStudent,
  updateStudent,
  deleteStudent,
};
