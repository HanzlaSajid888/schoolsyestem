/**
 * Standard JSON response helpers for consistent API shape.
 */

/**
 * Send a success response.
 * @param {import('express').Response} res
 * @param {*} data - Response payload
 * @param {string} message
 * @param {number} [statusCode=200]
 * @returns {import('express').Response}
 */
function successResponse(res, data, message, statusCode = 200) {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
  });
}

/**
 * Send a paginated list response.
 * @param {import('express').Response} res
 * @param {Array|*} data - List items
 * @param {{ page: number, limit: number, total: number, totalPages: number }} meta
 * @param {string} [message='Data fetched successfully']
 * @returns {import('express').Response}
 */
function paginatedResponse(res, data, meta, message = 'Data fetched successfully') {
  return res.status(200).json({
    success: true,
    message,
    data,
    meta: {
      page: meta.page,
      limit: meta.limit,
      total: meta.total,
      totalPages: meta.totalPages,
    },
  });
}

module.exports = { successResponse, paginatedResponse };
