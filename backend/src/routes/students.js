/**
 * Student routes — mount at /api/v1/students
 */

const express = require('express');

const studentController = require('../controllers/studentController');
const validate = require('../middleware/validate');
const { validateQuery } = require('../middleware/validate');
const validateObjectId = require('../middleware/validateObjectId');
const {
  createStudentSchema,
  updateStudentSchema,
  studentQuerySchema,
} = require('../validators/studentValidator');

const router = express.Router();

// List students with search, grade/section filters, and pagination
router.get(
  '/',
  validateQuery(studentQuerySchema),
  studentController.getStudents
);

// Get a single student by MongoDB ID
router.get('/:id', validateObjectId, studentController.getStudent);

// Enroll a new student
router.post('/', validate(createStudentSchema), studentController.createStudent);

// Update student details (partial update supported)
router.put(
  '/:id',
  validateObjectId,
  validate(updateStudentSchema),
  studentController.updateStudent
);

// Soft-delete student (blocked if pending invoices exist)
router.delete('/:id', validateObjectId, studentController.deleteStudent);

module.exports = router;
