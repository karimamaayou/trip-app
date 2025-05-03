const db = require('../config/db');

const User = {};

User.findByEmail = (email, callback) => {
    db.query('SELECT * FROM utilisateurs WHERE email = ?', [email], callback);
};

User.create = (userData, callback) => {
    db.query('INSERT INTO utilisateurs (nom, prenom, email, mot_de_passe, role) VALUES (?, ?, ?, ?, ?)', 
    [userData.nom, userData.prenom, userData.email, userData.mot_de_passe, userData.role], callback);
};

module.exports = User;