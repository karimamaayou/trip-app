const express = require('express');
const router = express.Router();
const friendsController = require('../controllers/friendsController');

// Get user's friends list
router.get('/:userId', friendsController.getUserFriends);

module.exports = router; 