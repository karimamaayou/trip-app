const express = require("express");
const path = require("path");
const {
  getAllVoyageurs,
  getAllGroupesVoyageurs,
  getAllstatique,
  getAllshort,
  login,
  getUsersByMonth,
  addVille,
  deleteVille,
  getAllVilles,
  updatCaution,
  getAllActivities,
  addActivity,
  deleteActivity,
} = require("../controllers/dashbordController");
const router = express.Router();

router.post("/login", login);
router.get("/voyageurs", getAllVoyageurs);
router.get("/groupesVoyageurs", getAllGroupesVoyageurs);
router.get("/statique", getAllstatique);
router.get("/short", getAllshort);
router.get("/users-by-month", getUsersByMonth);
router.get("/villes", getAllVilles);
router.post("/Addvilles", addVille);
router.delete("/villes/:villeId", deleteVille);
router.post("/Caution", updatCaution);

// Activity routes
router.get("/activities", getAllActivities);
router.post("/addactivities", addActivity);
router.delete("/activities/:id_activity", deleteActivity);



module.exports = router;
