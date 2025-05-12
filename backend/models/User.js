const pool = require('../config/db');

const User = {};

User.findByEmail = async (email) => {
    console.log("📥 Appel à findByEmail avec :", email);
    const [rows] = await pool.query('SELECT * FROM utilisateurs WHERE email = ?', [email]);
    console.log("📤 Résultat de la requête :", rows);
    return rows;
};

User.create = async (userData) => {
    console.log("📥 Appel à create avec :", userData);
    const [result] = await pool.query(
        'INSERT INTO utilisateurs (nom, prenom, email, mot_de_passe, role) VALUES (?, ?, ?, ?, ?)', 
        [userData.nom, userData.prenom, userData.email, userData.mot_de_passe, userData.role]
    );
    console.log("✅ Utilisateur inséré avec ID :", result.insertId);
    return result;
};

module.exports = User;