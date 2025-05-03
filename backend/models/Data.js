const db = require('../config/db');

const Data = {
    // Get all villes
    getAllVilles: async () => {
        try {
            const [villes] = await db.query(`
                SELECT id_ville, nom_ville
                FROM ville
                ORDER BY nom_ville
            `);
            return villes;
        } catch (error) {
            console.error('Error in getAllVilles:', error);
            throw error;
        }
    },

    // Get all activities
    getAllActivities: async () => {
        try {
            const [activities] = await db.query(`
                SELECT id_activity, nom_activity
                FROM activities
                ORDER BY nom_activity
            `);
            return activities;
        } catch (error) {
            console.error('Error in getAllActivities:', error);
            throw error;
        }
    }
};

module.exports = Data; 