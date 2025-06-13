const db = require("../config/db"); // Adapter selon votre config de connexion MySQL

// Fonction pour récupérer les amis acceptés
const User = {

  fetchAcceptedFriends: async (userId) => {
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
                    friend.photo_profil = `${friend.photo_profil}`;
                }
            });

            return friends;
        } catch (error) {
            console.error('Error in getUserFriends:', error);
            throw error;
        }
    },
fetchUserVoyages: (userId) => {
  return new Promise((resolve, reject) => {
    const sql = `
    SELECT 
    v.titre,
    v.budget,
    v.date_depart,
    ville_depart.nom_ville AS ville_depart,
    ville_destination.nom_ville AS ville_destination
FROM 
    voyages v
JOIN 
    ville ville_depart ON v.id_ville_depart = ville_depart.id_ville
JOIN 
    ville ville_destination ON v.id_ville_destination = ville_destination.id_ville
JOIN 
    messages_groupe mg ON v.id_voyage = mg.id_voyage
JOIN 
    utilisateurs u ON mg.id_auteur = u.id_utilisateur
WHERE 
    u.id_utilisateur = ?
GROUP BY 
    v.id_voyage;
    `;
    db.query(sql, [userId], (err, results) => {
      if (err) return reject(err);
      resolve(results);
    });
  });
}};
module.exports = User;  
