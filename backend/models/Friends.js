const db = require('../config/db');

const Friends = {
    getUserFriends: async (userId) => {
        try {
            const [friends] = await db.query(`
                SELECT 
                    u.id_utilisateur,
                    u.nom,
                    u.prenom,
                    u.email,
                    u.photo_profil,
                    u.role,
                    u.date_inscription
                FROM amis a
                JOIN utilisateurs u ON a.id_ami = u.id_utilisateur
                WHERE a.id_utilisateur = ?
                ORDER BY u.nom, u.prenom
            `, [userId]);

            // Convert photo_profil paths to full URLs
            friends.forEach(friend => {
                if (friend.photo_profil) {
                    friend.photo_profil = `/uploads/profile_pictures/${friend.photo_profil}`;
                }
            });

            return friends;
        } catch (error) {
            console.error('Error in getUserFriends:', error);
            throw error;
        }
    }
};

module.exports = Friends; 