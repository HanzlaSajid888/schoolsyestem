const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { StatusCodes } = require('http-status-codes');

// Generate JWT
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET || 'secret123', {
    expiresIn: '30d',
  });
};

/**
 * @desc    Register new admin user
 * @route   POST /api/v1/auth/register
 * @access  Public (Should be secured in production)
 */
exports.register = async (req, res, next) => {
  const { name, email, password } = req.body;

  if (!name || !email || !password) {
    return res.status(StatusCodes.BAD_REQUEST).json({
      success: false,
      message: 'Please provide all required fields',
    });
  }

  // Check if user exists
  const userExists = await User.findOne({ email });

  if (userExists) {
    return res.status(StatusCodes.BAD_REQUEST).json({
      success: false,
      message: 'User already exists',
    });
  }

  // Create user
  const user = await User.create({
    name,
    email,
    password,
  });

  if (user) {
    res.status(StatusCodes.CREATED).json({
      success: true,
      data: {
        _id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        token: generateToken(user._id),
      },
    });
  } else {
    res.status(StatusCodes.BAD_REQUEST).json({
      success: false,
      message: 'Invalid user data',
    });
  }
};

/**
 * @desc    Authenticate a user
 * @route   POST /api/v1/auth/login
 * @access  Public
 */
exports.login = async (req, res, next) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(StatusCodes.BAD_REQUEST).json({
      success: false,
      message: 'Please provide an email and password',
    });
  }

  // Check for user email
  const user = await User.findOne({ email }).select('+password');

  if (!user) {
    return res.status(StatusCodes.UNAUTHORIZED).json({
      success: false,
      message: 'Invalid credentials',
    });
  }

  // Check if password matches
  const isMatch = await user.matchPassword(password);

  if (!isMatch) {
    return res.status(StatusCodes.UNAUTHORIZED).json({
      success: false,
      message: 'Invalid credentials',
    });
  }

  res.status(StatusCodes.OK).json({
    success: true,
    data: {
      _id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      token: generateToken(user._id),
    },
  });
};

/**
 * @desc    Get current logged in user
 * @route   GET /api/v1/auth/me
 * @access  Private
 */
exports.getMe = async (req, res, next) => {
  const user = await User.findById(req.user.id);

  res.status(StatusCodes.OK).json({
    success: true,
    data: user,
  });
};
