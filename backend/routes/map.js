const express = require('express');
const router = express.Router();
const mapController = require('../controllers/mapController');

router.get('/voyages', mapController.getAllVoyages);


router.post('/update', mapController.updateUserLocation);




module.exports = router;
