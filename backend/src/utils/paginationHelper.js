/**
 * Pagination utilities for list endpoints.
 */

const { PAGINATION } = require('../config/constants');

/**
 * Parse page and limit from query string and compute MongoDB skip.
 * @param {object} query - Typically req.query
 * @returns {{ skip: number, limit: number, page: number }}
 * @example
 * // page=2, limit=20 → { page: 2, limit: 20, skip: 20 }
 */
function getPagination(query) {
  let page = parseInt(query.page, 10) || PAGINATION.DEFAULT_PAGE;
  let limit = parseInt(query.limit, 10) || PAGINATION.DEFAULT_LIMIT;

  if (page < 1) page = PAGINATION.DEFAULT_PAGE;
  if (limit < 1) limit = PAGINATION.DEFAULT_LIMIT;
  if (limit > PAGINATION.MAX_LIMIT) limit = PAGINATION.MAX_LIMIT;

  const skip = (page - 1) * limit;

  return { skip, limit, page };
}

/**
 * Build pagination meta for paginatedResponse.
 * @param {number} total - Total document count
 * @param {number} page
 * @param {number} limit
 * @returns {{ page: number, limit: number, total: number, totalPages: number }}
 */
function buildPaginationMeta(total, page, limit) {
  const totalPages = Math.ceil(total / limit) || 1;
  return { page, limit, total, totalPages };
}

module.exports = { getPagination, buildPaginationMeta };
