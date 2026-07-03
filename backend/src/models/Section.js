/**
 * @file Section Mongoose model — lookup list for Flutter dropdowns.
 * Examples: "Section A", "Section B".
 */

const mongoose = require('mongoose');

/**
 * Standardize section name (e.g. "section a" → "Section A").
 * @param {string} name
 * @returns {string}
 */
function standardizeSectionName(name) {
  return String(name)
    .trim()
    .toLowerCase()
    .replace(/\b\w/g, (char) => char.toUpperCase());
}

const sectionSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Section name is required'],
      unique: true,
      trim: true,
      minlength: [1, 'Section name is required'],
      maxlength: [20, 'Section name cannot exceed 20 characters'],
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
sectionSchema.pre('save', function (next) {
  if (this.name) {
    this.name = standardizeSectionName(this.name);
  }
  next();
});

/**
 * Find an existing section by name or create a new one.
 * @param {string} name
 * @returns {Promise<{ doc: import('mongoose').Document, created: boolean }>}
 */
sectionSchema.statics.findOrCreate = async function (name) {
  const normalized = standardizeSectionName(name);

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

const Section = mongoose.model('Section', sectionSchema);

module.exports = Section;
