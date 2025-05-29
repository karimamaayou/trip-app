const express = require('express');
const router = express.Router();
const postController = require('../controllers/postController');
const pool = require('../config/db');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Ensure upload directory exists
const uploadDir = 'uploads/post_images';
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Configure multer for image upload
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ storage: storage });

// Get all posts
router.get('/', postController.getAllPosts);

// Create a new post
router.post('/', async (req, res) => {
  try {
    const { content, userId } = req.body;
    
    if (!content || !userId) {
      return res.status(400).json({ message: 'Content and userId are required' });
    }

    const [result] = await pool.query(
      'INSERT INTO posts (contenu, id_auteur, date_publication) VALUES (?, ?, NOW())',
      [content, userId]
    );

    // Get the created post with user details
    const [newPost] = await pool.query(`
      SELECT p.*, u.nom, u.prenom, u.photo_profil
      FROM posts p
      JOIN utilisateurs u ON p.id_auteur = u.id_utilisateur
      WHERE p.id_post = ?
    `, [result.insertId]);

    res.status(201).json(newPost[0]);
  } catch (error) {
    console.error('Error creating post:', error);
    res.status(500).json({ message: 'Error creating post', error: error.message });
  }
});

// Upload images for a post
router.post('/:postId/images', upload.array('images', 6), async (req, res) => {
  try {
    const postId = req.params.postId;
    const files = req.files;

    if (!files || files.length === 0) {
      return res.status(400).json({ message: 'No images provided' });
    }

    // Insert image records into the database
    for (const file of files) {
      const imagePath = `/uploads/post_images/${file.filename}`;
      await pool.query(
        'INSERT INTO images (chemin, id_post) VALUES (?, ?)',
        [imagePath, postId]
      );
    }

    // Get all images for the post
    const [images] = await pool.query(
      'SELECT * FROM images WHERE id_post = ?',
      [postId]
    );

    res.json({ 
      message: 'Images uploaded successfully',
      images: images
    });
  } catch (error) {
    console.error('Error uploading post images:', error);
    // If there's an error, try to clean up any uploaded files
    if (req.files) {
      for (const file of req.files) {
        try {
          fs.unlinkSync(file.path);
        } catch (unlinkError) {
          console.error('Error deleting file:', unlinkError);
        }
      }
    }
    res.status(500).json({ message: 'Error uploading images', error: error.message });
  }
});

// Toggle reaction on a post
router.post('/:id_post/reactions', postController.toggleReaction);

module.exports = router; 