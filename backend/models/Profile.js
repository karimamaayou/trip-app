const db = require('../config/db');

const Profile = {
    getUserProfile: async (userId) => {
        try {
            const [user] = await db.query(`
                SELECT id_utilisateur, nom, prenom, email, photo_profil
                FROM utilisateurs
                WHERE id_utilisateur = ?
            `, [userId]);

            return user || null;
        } catch (error) {
            console.error('Error in getUserProfile:', error);
            throw error;
        }
    },

    updateUserProfile: async (userId, profileData) => {
        try {
            const { nom, prenom, email, photo_profil } = profileData;
            
            await db.query(`
                UPDATE utilisateurs
                SET nom = ?,
                    prenom = ?,
                    email = ?,
                    photo_profil = ?
                WHERE id_utilisateur = ?
            `, [nom, prenom, email, photo_profil, userId]);

            return true;
        } catch (error) {
            console.error('Error in updateUserProfile:', error);
            throw error;
        }
    }
};

module.exports = Profile;
