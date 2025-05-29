const db = require('../config/db');

const userController = {
    // Get user profile by ID
    getUserProfile: async (req, res) => {
        try {
            const { userId } = req.params;
            
            const [users] = await db.query(`
                SELECT 
                    id_utilisateur,
                    nom,
                    prenom,
                    email,
                    photo_profil,
                    role,
                    date_inscription
                FROM utilisateurs
                WHERE id_utilisateur = ?
            `, [userId]);

            if (users.length === 0) {
                return res.status(404).json({ message: 'User not found' });
            }

            const user = users[0];
            
            // Format photo_profil path
            if (user.photo_profil) {
                user.photo_profil = `${user.photo_profil}`;
            }

            res.json(user);
        } catch (error) {
            console.error('Error getting user profile:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    // Change user password
    changePassword: async (req, res) => {
        const { userId } = req.params;
        const { oldPassword, newPassword } = req.body;

        if (!oldPassword || !newPassword) {
            return res.status(400).json({ message: 'Veuillez fournir l\'ancien et le nouveau mot de passe.' });
        }

        try {
            // Fetch the user's current password from the database
            const [users] = await db.query(
                'SELECT mot_de_passe FROM utilisateurs WHERE id_utilisateur = ?',
                [userId]
            );

            if (users.length === 0) {
                return res.status(404).json({ message: 'Utilisateur non trouvé.' });
            }

            const currentPassword = users[0].mot_de_passe;

            // Simple comparison (no hashing)
            if (oldPassword !== currentPassword) {
                return res.status(401).json({ message: 'L\'ancien mot de passe est incorrect.' });
            }

            // Update the password (no hashing)
            await db.query(
                'UPDATE utilisateurs SET mot_de_passe = ? WHERE id_utilisateur = ?',
                [newPassword, userId]
            );

            res.status(200).json({ message: 'Mot de passe changé avec succès.' });

        } catch (error) {
            console.error('Error changing password:', error);
            res.status(500).json({ message: 'Erreur interne du serveur lors du changement de mot de passe.' });
        }
    }
};

module.exports = userController; 