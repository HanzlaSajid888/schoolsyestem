/**
 * Reusable Joi validation middleware factory.
 *
 * @example
 * router.post('/', validate(createSchema), controller.create);
 * router.get('/', validate(querySchema, 'query'), controller.list);
 *
 * @param {import('joi').ObjectSchema} schema
 * @param {'body'|'query'} [source='body']
 * @returns {import('express').RequestHandler}
 */
function validate(schema, source = 'body') {
  return (req, res, next) => {
    const isQuery = source === 'query';
    const target = isQuery ? req.query : req.body;

    const { error, value } = schema.validate(target, {
      abortEarly: false,
      stripUnknown: true,
      convert: isQuery,
    });

    if (error) {
      error.statusCode = 422;
      return next(error);
    }

    if (isQuery) {
      req.query = value;
    } else {
      req.body = value;
    }

    next();
  };
}

/**
 * @param {import('joi').ObjectSchema} schema
 * @returns {import('express').RequestHandler}
 */
function validateQuery(schema) {
  return validate(schema, 'query');
}

module.exports = validate;
module.exports.validateQuery = validateQuery;
