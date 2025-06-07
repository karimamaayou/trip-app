const db = require('../config/db');

class Position {
  static async createCoordinates(voyageId, latitude, longitude) {
    try {
      console.log('Creating coordinates with:', { voyageId, latitude, longitude });
      
      const [result] = await db.execute(
        'UPDATE voyages SET latitude = ?, longitude = ? WHERE id_voyage = ?',
        [latitude, longitude, voyageId]
      );
      
      console.log('Database result:', result);
      return result.affectedRows > 0;
    } catch (error) {
      console.error('Error creating coordinates:', error);
      return false;
    }
  }

  static async updateCoordinates(voyageId, latitude, longitude) {
    try {
      const [result] = await db.execute(
        'UPDATE voyages SET latitude = ?, longitude = ? WHERE id_voyage = ?',
        [latitude, longitude, voyageId]
      );
      return result.affectedRows > 0;
    } catch (error) {
      console.error('Error updating coordinates:', error);
      return false;
    }
  }

  static async getCoordinates(voyageId) {
    try {
      const [rows] = await db.execute(
        'SELECT latitude, longitude FROM voyages WHERE id_voyage = ?',
        [voyageId]
      );
      return rows.length ? rows[0] : null;
    } catch (error) {
      console.error('Error getting coordinates:', error);
      return null;
    }
  }
}

module.exports = Position;