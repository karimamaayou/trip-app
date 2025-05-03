const User = require('../models/User');


exports.register = (req, res) => {
    const { nom, prenom, email, mot_de_passe, role } = req.body;

    if (!nom || !prenom || !email || !mot_de_passe) {
        return res.status(400).json({ message: 'Champs requis manquants' });
    }

    User.findByEmail(email, (err, results) => {
        if (err) return res.status(500).json({ message: 'Erreur serveur' });
        if (results.length > 0) return res.status(400).json({ message: 'Email déjà utilisé' });

        const newUser = { nom, prenom, email, mot_de_passe, role: role || 'voyageur' };

        User.create(newUser, (err, result) => {
            if (err) return res.status(500).json({ message: 'Erreur lors de la création' });
            res.status(201).json({ message: 'Utilisateur créé' });
        });
    });
};

exports.login = (req, res) => {
    const { email, mot_de_passe } = req.body;
    console.log(email,mot_de_passe);

    if (!email || !mot_de_passe) {
        return res.status(400).json({ message: 'Email et mot de passe requis' });
    }

    User.findByEmail(email, (err, results) => {
        if (err) return res.status(500).json({ message: 'Erreur serveur' });
        if (results.length === 0) return res.status(401).json({ message: 'Email ou mot de passe incorrect' });

        const user = results[0];
        if (mot_de_passe !== user.mot_de_passe) {
            return res.status(401).json({ message: 'Email ou mot de passe incorrect' });
        }

        res.json({ message: 'Connexion réussie' });
    });
};
