/**
 * Joi validation schemas for Section routes.
 */

const Joi = require('joi');

const sectionSchema = Joi.object({
  name: Joi.string().trim().min(2).max(50).required().messages({
    'string.empty': 'Section name is required',
    'any.required': 'Section name is required',
  }),
});

module.exports = { sectionSchema };
