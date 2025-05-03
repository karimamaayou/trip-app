const express = require('express');
const router = express.Router();
const dataController = require('../controllers/dataController');

// Get all villes
router.get('/villes', dataController.getVilles);

// Get all activities
router.get('/activities', dataController.getActivities);

module.exports = router; 