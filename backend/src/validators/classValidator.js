/**
 * Joi validation schemas for Class routes.
 */

const Joi = require('joi');

const classSchema = Joi.object({
  name: Joi.string().trim().min(2).max(50).required().messages({
    'string.empty': 'Class name is required',
    'any.required': 'Class name is required',
  }),
});

module.exports = { classSchema };
