const express = require('express');
const eventController = require('../controllers/eventController');
const validate = require('../middleware/validate');
const { createEventSchema } = require('../validators/eventValidator');

const router = express.Router();

router.get('/', eventController.getEvents);
router.post('/', validate(createEventSchema), eventController.createEvent);
router.delete('/:id', eventController.deleteEvent);

module.exports = router;
