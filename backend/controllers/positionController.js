const Position = require('../models/positionModel');

exports.createPosition = async (req, res) => {
  try {
    console.log('Received request body:', req.body);
    console.log('Request headers:', req.headers);
    
    // Vérifier si req.body existe
    if (!req.body) {
      console.log('Request body is missing');
      return res.status(400).json({
        success: false,
        message: 'Request body is missing'
      });
    }

    // Extraire les valeurs de manière sécurisée
    const id_voyage = req.body.id_voyage;
    const latitude = req.body.latitude;
    const longitude = req.body.longitude;

    console.log('Extracted values:', { 
      id_voyage, 
      latitude, 
      longitude,
      id_voyage_type: typeof id_voyage,
      latitude_type: typeof latitude,
      longitude_type: typeof longitude
    });

    // Vérification plus stricte des valeurs
    if (!id_voyage || id_voyage === 'null' || id_voyage === 'undefined') {
      console.log('Invalid id_voyage:', id_voyage);
      return res.status(400).json({
        success: false,
        message: 'Invalid voyage ID'
      });
    }

    if (typeof latitude !== 'number' || isNaN(latitude)) {
      console.log('Invalid latitude:', latitude);
      return res.status(400).json({
        success: false,
        message: 'Invalid latitude value'
      });
    }

    if (typeof longitude !== 'number' || isNaN(longitude)) {
      console.log('Invalid longitude:', longitude);
      return res.status(400).json({
        success: false,
        message: 'Invalid longitude value'
      });
    }

    const created = await Position.createCoordinates(id_voyage, latitude, longitude);
    console.log('Creation result:', created);

    if (!created) {
      return res.status(400).json({
        success: false,
        message: 'Failed to create position - voyage might not exist'
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Position created successfully',
      data: { id_voyage, latitude, longitude }
    });
  } catch (error) {
    console.error('Error creating position:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

exports.updatePosition = async (req, res) => {
  try {
    const { id } = req.params;
    const { latitude, longitude } = req.body;

    if (!latitude || !longitude) {
      return res.status(400).json({
        success: false,
        message: 'Both latitude and longitude are required'
      });
    }

    const updated = await Position.updateCoordinates(id, latitude, longitude);

    if (!updated) {
      return res.status(404).json({
        success: false,
        message: 'Voyage not found'
      });
    }

    res.json({
      success: true,
      message: 'Coordinates updated successfully',
      data: { latitude, longitude }
    });
  } catch (error) {
    console.error('Error updating coordinates:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

exports.getPosition = async (req, res) => {
  try {
    const { id } = req.params;
    const coordinates = await Position.getCoordinates(id);

    if (!coordinates) {
      return res.status(404).json({
        success: false,
        message: 'Voyage not found or coordinates not set'
      });
    }

    res.json({
      success: true,
      data: coordinates
    });
  } catch (error) {
    console.error('Error getting coordinates:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};