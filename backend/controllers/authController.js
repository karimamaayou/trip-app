const User = require('../models/User');



exports.register = async (req, res) => {
    const { nom, prenom, email, mot_de_passe } = req.body;

    console.log(nom, prenom, email, mot_de_passe);

    if (!nom || !prenom || !email || !mot_de_passe) {
        return res.status(400).json({ message: 'Champs requis manquants' });
    }

    try {
        // Vérifier si l'email est déjà utilisé
        const results = await User.findByEmail(email);

        if (results.length > 0) {
            return res.status(400).json({ message: 'Email déjà utilisé' });
        }

        // Créer le nouvel utilisateur
        const newUser = { nom, prenom, email, mot_de_passe, role: 'Utilisateur' };

        const result = await User.create(newUser);
        res.status(200).json({ message: 'Utilisateur créé', userId: result.insertId });

    } catch (err) {
        console.error("❌ Erreur serveur :", err);
        res.status(500).json({ message: 'Erreur serveur' });
    }
};


exports.login = async (req, res) => {
    const { email, mot_de_passe } = req.body;
    console.log(email, mot_de_passe);

    if (!email || !mot_de_passe) {
        return res.status(400).json({ message: 'Email et mot de passe requis' });
    }

    try {
        const results = await User.findByEmail(email);

        if (results.length === 0) {
            return res.status(401).json({ message: 'Email ou mot de passe incorrect' });
        }

        const user = results[0];

        if (mot_de_passe !== user.mot_de_passe) {
            return res.status(401).json({ message: 'Email ou mot de passe incorrect' });
        }

        res.status(200).json({
            message: 'Connexion réussie',
            user: {
                id: user.id_utilisateur,
                nom: user.nom,
                prenom: user.prenom,
                email: user.email,
                profilePicture: user.photo_profil,
                role: user.role
            }
        });

    } catch (err) {
        console.error("❌ Erreur serveur :", err);
        res.status(500).json({ message: 'Erreur serveur' });
    }
};

