const express = require('express');
const router = express.Router();
const postController = require('../controllers/postController');

// Get all posts
router.get('/posts', postController.getAllPosts);

// Toggle reaction on a post
router.post('/posts/:id_post/reactions', postController.toggleReaction);

module.exports = router; 