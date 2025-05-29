const express = require('express');
const router = express.Router();
const mapController = require('../controllers/mapController');

// Get all voyages
router.get('/', mapController.getAllVoyages);

// Update user location
router.post('/update', mapController.updateUserLocation);

module.exports = router;
