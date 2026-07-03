/**
 * Joi validation schemas for Student routes.
 */

const Joi = require('joi');

const ROLL_NUMBER_PATTERN = /^\d{4}-\d{3}$/;
const PHONE_PATTERN = /^(\+92|0)[0-9]{10}$/;
const AVATAR_COLOR_PATTERN = /^(0x|#)?[0-9A-Fa-f]{6,8}$/;

/** Shared field definitions */
const studentFields = {
  firstName: Joi.string().trim().min(2).max(50),
  lastName: Joi.string().trim().min(2).max(50),
  email: Joi.string().email().lowercase().trim(),
  rollNumber: Joi.string().trim().pattern(ROLL_NUMBER_PATTERN).messages({
    'string.pattern.base': 'Roll number must match format 2024-001',
  }),
  grade: Joi.string().trim(),
  section: Joi.string().trim(),
  parentName: Joi.string().trim().min(2).max(100),
  phone: Joi.string().trim().pattern(PHONE_PATTERN).messages({
    'string.pattern.base': 'Please provide a valid Pakistani phone number',
  }),
  parentEmail: Joi.string().email().lowercase().trim().allow('', null),
  avatarColor: Joi.string().pattern(AVATAR_COLOR_PATTERN).messages({
    'string.pattern.base': 'Avatar color must be a valid color code (e.g. 0xFFE3F2FD)',
  }),
};

/**
 * POST /students — create a new student.
 */
const createStudentSchema = Joi.object({
  firstName: studentFields.firstName.required(),
  lastName: studentFields.lastName.required(),
  email: studentFields.email.required(),
  rollNumber: studentFields.rollNumber.required(),
  grade: studentFields.grade.required(),
  section: studentFields.section.required(),
  parentName: studentFields.parentName.required(),
  phone: studentFields.phone.required(),
  parentEmail: studentFields.parentEmail.optional(),
  avatarColor: studentFields.avatarColor.optional(),
});

/**
 * PUT /students/:id — partial update (at least one field required).
 */
const updateStudentSchema = Joi.object({
  firstName: studentFields.firstName,
  lastName: studentFields.lastName,
  email: studentFields.email,
  rollNumber: studentFields.rollNumber,
  grade: studentFields.grade,
  section: studentFields.section,
  parentName: studentFields.parentName,
  phone: studentFields.phone,
  parentEmail: studentFields.parentEmail,
  avatarColor: studentFields.avatarColor,
  isActive: Joi.boolean(),
})
  .min(1)
  .messages({
    'object.min': 'At least one field is required to update',
  });

/**
 * GET /students — list query parameters.
 */
const studentQuerySchema = Joi.object({
  search: Joi.string().trim().max(100).optional().allow(''),
  grade: Joi.string().trim().optional().allow(''),
  section: Joi.string().trim().optional().allow(''),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20),
  isActive: Joi.boolean().default(true),
});

module.exports = {
  createStudentSchema,
  updateStudentSchema,
  studentQuerySchema,
};
