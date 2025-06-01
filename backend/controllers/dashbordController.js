const User = require("../models/dahbordModels"); 

exports.getAllVoyageurs = async (req, res) => {
  try {
    const results = await User.getAllVoyageurs();
    res.json(results);
  } catch (err) {
    console.error("Erreur lors de la récupération des clients:", err);
    res.status(500).json({ message: "Erreur interne du serveur", error: err });
  }
};

exports.getAllGroupesVoyageurs = async (req, res) => {
  try {
    const results = await User.getAllGroupesVoyageurs();
    res.json(results);
  } catch (err) {
    console.error("Erreur lors de la récupération des clients:", err);
    res.status(500).json({ message: "Erreur interne du serveur", error: err });
  }
};

exports.getAllstatique = async (req, res) => {
  try {
    const results = await User.getAllstatique();
    res.json(results);
  } catch (err) {
    console.error("Erreur lors de la récupération des clients:", err);
    res.status(500).json({ message: "Erreur interne du serveur", error: err });
  }
};

exports.getAllshort = async (req, res) => {
  try {
    const results = await User.getAllshort();
    res.json(results);
  } catch (err) {
    console.error("Erreur lors de la récupération des clients:", err);
    res.status(500).json({ message: "Erreur interne du serveur", error: err });
  }
};
 
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validation de l'email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!email || !emailRegex.test(email)) {
      return res
        .status(400)
        .json({ message: "Veuillez entrer une adresse email valide" });
    }

    if (!password) {
      return res.status(400).json({ message: "Le mot de passe est requis" });
    }

    const user = await User.login(email, password);

    if (!user) {
      return res
        .status(401)
        .json({ message: "Email ou mot de passe incorrect" });
    }

    // Comparaison directe du mot de passe
    if (password !== user.mot_de_passe) {
      return res
        .status(401)
        .json({ message: "Email ou mot de passe incorrect" });
    }

    // Retourner les informations de l'utilisateur (sans le mot de passe)
    const { mot_de_passe, ...userInfo } = user;
    res.json({
      message: "Connexion réussie",
      user: userInfo,
    });
  } catch (err) {
    console.error("Erreur lors de la connexion:", err);
    res.status(500).json({ message: "Erreur interne du serveur", error: err });
  }
};

exports.getUsersByMonth = async (req, res) => {
  try {
    const results = await User.getUsersByMonth();

    // Transformer les données pour inclure les noms des mois
    const monthNames = [
      "Janvier",
      "Février",
      "Mars",
      "Avril",
      "Mai",
      "Juin",
      "Juillet",
      "Août",
      "Septembre",
      "Octobre",
      "Novembre",
      "Décembre",
    ];

    const formattedResults = results.map((item) => ({
      month: monthNames[item.month - 1],
      count: item.count,
    }));

    res.json(formattedResults);
  } catch (err) {
    console.error(
      "Erreur lors de la récupération des données du graphique:",
      err
    );
    res.status(500).json({ message: "Erreur interne du serveur", error: err });
  }
};

exports.addVille = async (req, res) => {
  try {
    const { nom_ville } = req.body;

    // Validation des données
    if (!nom_ville) {
      return res.status(400).json({
        message: "Le nom de la ville est obligatoire",
      });
    }

    // Vérifier si la ville existe déjà
    const existingVille = await User.checkVilleExists(nom_ville);
    if (existingVille) {
      return res.status(400).json({
        message: "Cette ville existe déjà",
      });
    }

    // Ajouter la ville
    const villeId = await User.addVille({
      nom_ville,
    });

    res.status(201).json({
      message: "Ville ajoutée avec succès",
      villeId: villeId,
      nom_ville: nom_ville,
    });
  } catch (err) {
    console.error("Erreur lors de l'ajout de la ville:", err);
    res.status(500).json({
      message: "Erreur lors de l'ajout de la ville",
      error: err.message,
    });
  }
};

exports.deleteVille = async (req, res) => {
  try {
    const { villeId } = req.params;

    if (!villeId) {
      return res.status(400).json({ message: "ID de la ville requis" });
    }

    try {
      const deleted = await User.deleteVille(villeId);
      if (!deleted) {
        return res.status(404).json({ message: "Ville non trouvée" });
      }

      // ✅ Ajout du code HTTP 200
      res.status(200).json({ message: "Ville supprimée avec succès" });
    } catch (error) {
      if (error.message.includes("utilisée dans des voyages")) {
        return res.status(400).json({
          message:
            "Impossible de supprimer cette ville car elle est utilisée dans des voyages",
          details:
            "Vous devez d'abord supprimer ou modifier les voyages qui utilisent cette ville",
        });
      }
      throw error;
    }
  } catch (err) {
    console.error("Erreur lors de la suppression de la ville:", err);
    res.status(500).json({ message: "Erreur interne du serveur", error: err });
  }
};

exports.getAllVilles = async (req, res) => {
  try {
    const villes = await User.getAllVilles();
    res.json(villes);
  } catch (err) {
    console.error("Erreur lors de la récupération des villes:", err);
    res.status(500).json({ message: "Erreur interne du serveur", error: err });
  }
};
// Route : /api/utilisateurs/:id/caution
exports.updatCaution = async (req, res) => {
  try {
    const { id_utilisateur } = req.body;

    if (!id_utilisateur) {
      return res.status(400).json({ message: "id_utilisateur manquant" });
    }

    const result = await User.updateCaution(id_utilisateur);
    if (!result) {
      return res.status(404).json({ message: "Utilisateur non trouvé" });
    }
    res.json({ success: true, result });
  } catch (err) {
    console.error("Erreur lors de la mise à jour de la caution:", err);
    res
      .status(500)
      .json({ message: "Erreur interne du serveur", error: err.message });
  }
};

exports.getAllActivities = async (req, res) => {
  try {
    const activities = await User.getAllActivities();
    res.json(activities);
  } catch (err) {
    console.error("Erreur lors de la récupération des activités:", err);
    res
      .status(500)
      .json({ message: "Erreur interne du serveur", error: err.message });
  }
};

exports.addActivity = async (req, res) => {
  try {
    const { nom_activity } = req.body;

    if (!nom_activity) {
      return res
        .status(400)
        .json({ message: "Le nom de l'activité est requis" });
    }

    const activityId = await User.addActivity(nom_activity);
    res.status(201).json({
      message: "Activité ajoutée avec succès",
      activityId,
      nom_activity,
    });
  } catch (err) {
    console.error("Erreur lors de l'ajout de l'activité:", err);
    res
      .status(500)
      .json({ message: "Erreur interne du serveur", error: err.message });
  }
};

exports.deleteActivity = async (req, res) => {
  try {
    const { id_activity } = req.params;

    if (!id_activity) {
      return res.status(400).json({ message: "ID de l'activité requis" });
    }

    const deleted = await User.deleteActivity(id_activity);
    if (!deleted) {
      return res.status(404).json({ message: "Activité non trouvée" });
    }

    res.status(200).json({ message: "Activité supprimée avec succès" });
  } catch (err) {
    console.error("Erreur lors de la suppression de l'activité:", err);
    res
      .status(500)
      .json({ message: "Erreur interne du serveur", error: err.message });
  }
};
