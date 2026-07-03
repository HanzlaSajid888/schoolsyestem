/**
 * Fee calculation business logic — single source of truth for tuition amounts.
 * Pure functions only; does not import models.
 */

const { FEE_RULES, CURRENCY } = require('../config/constants');

/**
 * Resolve monthly tuition (PKR) for a grade label.
 * @param {string} [grade] - e.g. "Grade 10"
 * @returns {number} Fee amount in PKR (never null or undefined)
 */
function calculateFeeForGrade(grade) {
  if (grade && Object.prototype.hasOwnProperty.call(FEE_RULES, grade)) {
    return FEE_RULES[grade];
  }

  return FEE_RULES.DEFAULT;
}

/**
 * Full fee schedule for API responses.
 * @returns {{ grade: string, amount: number, currency: string }[]}
 */
function getFeeSchedule() {
  return Object.entries(FEE_RULES)
    .filter(([key]) => key !== 'DEFAULT')
    .map(([grade, amount]) => ({
      grade,
      amount,
      currency: CURRENCY,
    }));
}

/**
 * Verify that an amount matches the expected fee for a grade.
 * @param {string} grade
 * @param {number} amount
 * @returns {boolean}
 */
function validateFeeCalculation(grade, amount) {
  return calculateFeeForGrade(grade) === amount;
}

module.exports = {
  calculateFeeForGrade,
  getFeeSchedule,
  validateFeeCalculation,
};
