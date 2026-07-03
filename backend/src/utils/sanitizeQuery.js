/**
 * Remove undefined and null values from a plain object before Mongoose queries.
 * Prevents accidental broad matches when optional filters are omitted.
 */

/**
 * @param {object} query
 * @returns {object}
 */
function sanitizeQuery(query = {}) {
  return Object.fromEntries(
    Object.entries(query).filter(([, value]) => value !== undefined && value !== null)
  );
}

module.exports = sanitizeQuery;
