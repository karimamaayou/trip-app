
const User = require("../models/profileVoyegeurModels"); 
// Contrôleur pour obtenir la liste des amis acceptés d'un utilisateur

exports.fetchAcceptedFriends = async (req, res) => {
    const userId = req.params.id;

    try {
        const friends = await User.fetchAcceptedFriends(userId);

        if (!friends || friends.length === 0) {
            return res.status(404).json({ message: "Aucun ami accepté trouvé." });
        }

        res.status(200).json(friends);
    } catch (error) {
        console.error('Erreur dans getAcceptedFriends:', error);
        res.status(500).json({ error: 'Erreur interne du serveur.' });
    }
};

exports.fetchUserVoyages = async (req, res) => {
  const userId = req.params.id;
  try {
    console.log(`Fetching voyages for user ${userId}`); // Debug log
    const voyages = await User.fetchUserVoyages(userId);
    console.log('Voyages found:', voyages); // Debug log
    res.status(200).json(voyages);
  } catch (error) {
    console.error("Detailed error:", error);
    res.status(500).json({ error: "Erreur lors de la récupération des voyages." });
  } 
};


