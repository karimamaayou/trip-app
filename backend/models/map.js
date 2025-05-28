const db = require('../config/db'); // Assure-toi que c'est bien un pool promisifié

const getAllVoyages = async () => {
  try {
    const [rows] = await db.query(`
      SELECT v.id_voyage AS id, v.titre, i.chemin, v.latitude AS lat, v.longitude AS lng 
      FROM voyages v 
      JOIN images i ON v.id_voyage = i.id_voyage
      GROUP BY v.id_voyage
    `);
    return rows;
  } catch (err) {
    console.error('Erreur dans getAllVoyages:', err);
    throw err;
  }
};

module.exports = {
  getAllVoyages,
};
