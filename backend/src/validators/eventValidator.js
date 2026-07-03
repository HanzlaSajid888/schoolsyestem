const Joi = require('joi');

const createEventSchema = Joi.object({
  title: Joi.string().trim().min(2).max(100).required(),
  type: Joi.string().valid('Exam', 'Event', 'Meeting', 'Holiday', 'Other').required(),
  date: Joi.date().iso().required(),
});

module.exports = {
  createEventSchema,
};
