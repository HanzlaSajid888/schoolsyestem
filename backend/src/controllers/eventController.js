const { StatusCodes } = require('http-status-codes');
const Event = require('../models/Event');
const { successResponse } = require('../utils/responseFormatter');
const AppError = require('../utils/AppError');
const mongoose = require('mongoose');

async function getEvents(req, res, next) {
  try {
    const events = await Event.find({ isActive: true }).sort({ date: 1 });
    return successResponse(res, events, 'Events fetched successfully');
  } catch (error) {
    next(error);
  }
}

async function createEvent(req, res, next) {
  try {
    const event = await Event.create(req.body);
    return successResponse(res, event, 'Event created successfully', StatusCodes.CREATED);
  } catch (error) {
    next(error);
  }
}

async function deleteEvent(req, res, next) {
  try {
    const { id } = req.params;
    if (!mongoose.Types.ObjectId.isValid(id)) {
      throw new AppError('Invalid event ID', StatusCodes.BAD_REQUEST);
    }
    const event = await Event.findById(id);
    if (!event) {
      throw new AppError('Event not found', StatusCodes.NOT_FOUND);
    }
    event.isActive = false;
    await event.save();
    return successResponse(res, event, 'Event deleted successfully');
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getEvents,
  createEvent,
  deleteEvent,
};
