const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

// Get user profile by ID
router.get('/:userId', userController.getUserProfile);

// Change user password
router.post('/change-password/:userId', userController.changePassword);

module.exports = router; 