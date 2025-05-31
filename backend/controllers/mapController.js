const map = require('../models/map');
const db = require('../config/db');

const getAllVoyages = async (req, res) => {
  try {
    const voyages = await map.getAllVoyages();
    res.status(200).json(voyages);
  } catch (error) {
    console.error('Erreur lors de la récupération des voyages :', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};





const updateUserLocation = async (req, res) => {
  const { userId, lat, lng } = req.body;
  
  try {
    await db.query(
      'UPDATE utilisateurs SET latitude = ?, longitude = ? WHERE id_utilisateur = ?',
      [lat, lng, userId]
    );
    
    res.status(200).json({ 
      success: true, 
      message: 'Position mise à jour avec succès' 
    });
  } catch (error) {
    console.error('Erreur lors de la mise à jour de la position:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Erreur lors de la mise à jour de la position' 
    });
  }
};





module.exports = {
  getAllVoyages,
  updateUserLocation,
};
