/**
 * Student Mongoose model.
 * Maps to Flutter Student entity: enrollment, class/section, parent/guardian contact.
 * Referenced by Invoice via studentId.
 */

const mongoose = require('mongoose');

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const ROLL_NUMBER_REGEX = /^\d{4}-\d{3}$/;
const PHONE_REGEX = /^(\+92|0)[0-9]{10}$/;

const AVATAR_COLORS = [
  '0xFFE3F2FD',
  '0xFFE1F5FE',
  '0xFFE0F7FA',
  '0xFFF3E5F5',
  '0xFFE8F5E9',
  '0xFFFFF3E0',
];

/**
 * Pick a random avatar color for new students.
 * @returns {string}
 */
function pickAvatarColor() {
  return AVATAR_COLORS[Math.floor(Math.random() * AVATAR_COLORS.length)];
}

/**
 * Normalize roll number to YYYY-NNN format.
 * @param {string} value
 * @returns {string}
 */
function formatRollNumber(value) {
  if (!value) return value;

  const trimmed = String(value).trim();

  if (ROLL_NUMBER_REGEX.test(trimmed)) {
    return trimmed;
  }

  const digits = trimmed.replace(/\D/g, '');
  if (digits.length === 7) {
    return `${digits.slice(0, 4)}-${digits.slice(4)}`;
  }

  return trimmed;
}

const studentSchema = new mongoose.Schema(
  {
    firstName: {
      type: String,
      required: [true, 'First name is required'],
      trim: true,
      maxlength: [50, 'First name cannot exceed 50 characters'],
    },
    lastName: {
      type: String,
      required: [true, 'Last name is required'],
      trim: true,
      maxlength: [50, 'Last name cannot exceed 50 characters'],
    },
    email: {
      type: String,
      required: [true, 'Email is required'],
      unique: true,
      lowercase: true,
      trim: true,
      match: [EMAIL_REGEX, 'Please provide a valid email address'],
    },
    rollNumber: {
      type: String,
      required: [true, 'Roll number is required'],
      unique: true,
      trim: true,
      match: [ROLL_NUMBER_REGEX, 'Roll number must match format 2024-001'],
    },
    grade: {
      type: String,
      required: [true, 'Grade is required'],
      trim: true,
    },
    section: {
      type: String,
      required: [true, 'Section is required'],
      trim: true,
    },
    parentName: {
      type: String,
      required: [true, 'Parent name is required'],
      trim: true,
    },
    phone: {
      type: String,
      required: [true, 'Phone number is required'],
      trim: true,
      match: [PHONE_REGEX, 'Please provide a valid Pakistani phone number'],
    },
    parentEmail: {
      type: String,
      lowercase: true,
      trim: true,
      validate: {
        validator(value) {
          if (!value) return true;
          return EMAIL_REGEX.test(value);
        },
        message: 'Please provide a valid parent email address',
      },
    },
    avatarColor: {
      type: String,
      default: pickAvatarColor,
    },
    isActive: {
      type: Boolean,
      default: true,
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

studentSchema.virtual('fullName').get(function () {
  return `${this.firstName} ${this.lastName}`;
});

/**
 * Format rollNumber before save.
 */
studentSchema.pre('save', function (next) {
  if (this.rollNumber) {
    this.rollNumber = formatRollNumber(this.rollNumber);
  }
  next();
});

/**
 * Search students with filters and pagination for the list endpoint.
 * @param {string} [query] - Search term (name, roll number)
 * @param {object} [filters] - { grade?, section?, isActive? }
 * @param {object} [pagination] - { skip, limit, page }
 * @returns {Promise<{ data: import('mongoose').Document[], total: number, page: number, limit: number }>}
 */
studentSchema.statics.findBySearch = async function (
  query = '',
  filters = {},
  pagination = {}
) {
  const { skip = 0, limit = 20, page = 1 } = pagination;

  const filter = {
    isActive: filters.isActive !== undefined ? filters.isActive : true,
  };

  if (filters.grade) {
    filter.grade = filters.grade;
  }

  if (filters.section) {
    filter.section = filters.section;
  }

  const searchTerm = query?.trim();

  if (searchTerm) {
    const escaped = searchTerm.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    const regex = new RegExp(escaped, 'i');

    const searchConditions = [
      { firstName: regex },
      { lastName: regex },
      { rollNumber: regex },
    ];

    if (/^[\w\s-]+$/i.test(searchTerm)) {
      searchConditions.push({ $text: { $search: searchTerm } });
    }

    filter.$or = searchConditions;
  }

  const [data, total] = await Promise.all([
    this.find(filter).sort({ createdAt: -1 }).skip(skip).limit(limit),
    this.countDocuments(filter),
  ]);

  return { data, total, page, limit };
};

/**
 * Check whether a roll number is already taken.
 * @param {string} rollNumber
 * @param {import('mongoose').Types.ObjectId|string} [excludeId] - Current student ID (updates)
 * @returns {Promise<boolean>}
 */
studentSchema.statics.existsByRollNumber = async function (rollNumber, excludeId) {
  const filter = { rollNumber: formatRollNumber(rollNumber) };

  if (excludeId) {
    filter._id = { $ne: excludeId };
  }

  const count = await this.countDocuments(filter);
  return count > 0;
};

studentSchema.index({ grade: 1, section: 1 });
studentSchema.index({ firstName: 'text', lastName: 'text' });

const Student = mongoose.model('Student', studentSchema);

module.exports = Student;
