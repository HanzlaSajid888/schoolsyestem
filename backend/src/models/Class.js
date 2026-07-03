/**
 * @file Class (grade) Mongoose model — lookup list for Flutter dropdowns.
 * Examples: "Grade 9", "Grade 10".
 */

const mongoose = require('mongoose');

/**
 * Standardize class name (e.g. "grade 9" → "Grade 9").
 * @param {string} name
 * @returns {string}
 */
function standardizeClassName(name) {
  return String(name)
    .trim()
    .toLowerCase()
    .replace(/\b\w/g, (char) => char.toUpperCase());
}

const classSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Class name is required'],
      unique: true,
      trim: true,
      minlength: [3, 'Class name must be at least 3 characters'],
      maxlength: [50, 'Class name cannot exceed 50 characters'],
    },
  },
  {
    timestamps: true,
    toJSON: {
      virtuals: true,
      versionKey: false,
      transform(doc, ret) {
        ret.id = ret._id;
        delete ret._id;
        return ret;
      },
    },
  }
);

/**
 * Capitalize and format name before save.
 */
classSchema.pre('save', function (next) {
  if (this.name) {
    this.name = standardizeClassName(this.name);
  }
  next();
});

/**
 * Find an existing class by name or create a new one.
 * @param {string} name
 * @returns {Promise<{ doc: import('mongoose').Document, created: boolean }>}
 */
classSchema.statics.findOrCreate = async function (name) {
  const normalized = standardizeClassName(name);

  let doc = await this.findOne({ name: normalized });
  if (doc) return { doc, created: false };

  try {
    doc = await this.create({ name: normalized });
    return { doc, created: true };
  } catch (err) {
    if (err.code === 11000) {
      doc = await this.findOne({ name: normalized });
      return { doc, created: false };
    }
    throw err;
  }
};

const Class = mongoose.model('Class', classSchema);

module.exports = Class;
