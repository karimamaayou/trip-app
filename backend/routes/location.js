const express = require('express');
const router = express.Router();
const mapController = require('../controllers/mapController');

// Update user location
router.post('/update', mapController.updateUserLocation);

module.exports = router; 