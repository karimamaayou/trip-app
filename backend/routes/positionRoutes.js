const express = require('express');
const router = express.Router();
const positionController = require('../controllers/positioncontroller');

// POST /api/positions - Create new position
router.post('/', positionController.createPosition);

// PUT /api/positions/:id - Update position coordinates
router.put('/:id', positionController.updatePosition);

// GET /api/positions/:id - Get position coordinates
router.get('/:id', positionController.getPosition);

module.exports = router;