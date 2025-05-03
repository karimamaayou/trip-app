const Data = require('../models/Data');

const dataController = {
    // Get all villes
    getVilles: async (req, res) => {
        try {
            const villes = await Data.getAllVilles();
            res.json(villes);
        } catch (error) {
            console.error('Error getting villes:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    // Get all activities
    getActivities: async (req, res) => {
        try {
            const activities = await Data.getAllActivities();
            res.json(activities);
        } catch (error) {
            console.error('Error getting activities:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    }
};

module.exports = dataController; 