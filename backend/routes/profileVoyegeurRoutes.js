const express = require("express");
const {
  fetchAcceptedFriends,
  fetchUserVoyages,
} = require("../controllers/profileVoyegeurController");
const router = express.Router();

// Route pour obtenir la liste des amis acceptés d'un utilisateur
router.get("/amis/:id", fetchAcceptedFriends);
router.get("/Voyages/:id", fetchUserVoyages);
module.exports = router;

; 
