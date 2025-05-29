const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

// Get user profile by ID
router.get('/:userId', userController.getUserProfile);

module.exports = router; 