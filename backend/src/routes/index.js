/**
 * Master API router — mounts feature sub-routers.
 * Mounted in app.js at API_PREFIX (/api/v1).
 */

const express = require('express');

const studentsRoutes = require('./students');
const classesRoutes = require('./classes');
const sectionsRoutes = require('./sections');
const invoicesRoutes = require('./invoices');
const dashboardRoutes = require('./dashboard');
const eventsRoutes = require('./events');
const authRoutes = require('./auth');

const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

router.use('/auth', authRoutes);

// Protected Routes
router.use('/students', protect, studentsRoutes);
router.use('/classes', protect, classesRoutes);
router.use('/sections', protect, sectionsRoutes);
router.use('/invoices', protect, invoicesRoutes);
router.use('/dashboard', protect, dashboardRoutes);
router.use('/events', protect, eventsRoutes);

module.exports = router;
