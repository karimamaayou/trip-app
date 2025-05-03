const express = require('express');
const router = express.Router();
const profileController = require('../controllers/profileController');
const { uploadProfilePicture } = require('../middlewares/uploadMiddleware');

// Get user profile
router.get('/:userId', profileController.getUserProfile);

// Update user profile with image upload
router.put('/:userId', uploadProfilePicture, profileController.updateUserProfile);

module.exports = router;
