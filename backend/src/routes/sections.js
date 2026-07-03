/**
 * Section routes — mount at /api/v1/sections
 */

const express = require('express');

const sectionController = require('../controllers/sectionController');
const validate = require('../middleware/validate');
const { sectionSchema } = require('../validators/sectionValidator');

const router = express.Router();

// List all section options for dropdowns
router.get('/', sectionController.getSections);

// Add a new section or return existing match
router.post('/', validate(sectionSchema), sectionController.createSection);

module.exports = router;
