/**
 * Class routes — mount at /api/v1/classes
 */

const express = require('express');

const classController = require('../controllers/classController');
const validate = require('../middleware/validate');
const { classSchema } = require('../validators/classValidator');

const router = express.Router();

// List all grade/class options for dropdowns
router.get('/', classController.getClasses);

// Add a new class or return existing match
router.post('/', validate(classSchema), classController.createClass);

module.exports = router;
