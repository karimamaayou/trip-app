const express = require('express');
const router = express.Router();
const tripController = require('../controllers/tripController');

// Get all trips
router.get('/allTrips', tripController.getAllTrips);

// Get user's trips
router.get('/user/:userId', tripController.getUserTrips);

// Get detailed trip information by ID
router.get('/details/:tripId', tripController.getTripDetailsById);

// Get voyage participants
router.get('/:voyageId/participants', tripController.getVoyageParticipants);

// Get trip details
router.get('/:tripId', tripController.getTripDetails);

// Create a new trip
router.post('/', tripController.createTrip);

// Add activity to trip
router.post('/:tripId/activities', tripController.addActivity);

// Join a trip
router.post('/:tripId/join', tripController.joinTrip);

module.exports = router;
