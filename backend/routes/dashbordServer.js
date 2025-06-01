
const express = require("express");
const path = require("path");
const router = express.Router();
const isAuthenticated = (req, res, next) => {
  if (req.session && req.session.user) {
    next(); // L'utilisateur est connecté
  } else {
    res.redirect("/login.html"); // Redirection si non connecté
  }
};
router.get('/dashboard', isAuthenticated, (req, res) => {
    res.sendFile(path.join(__dirname, '../public/interface/dashboard.html'));
});

router.get("/interface/dashboard.html", (req, res) => {
  res.sendFile(path.join(__dirname, "../public/interface/dashboard.html"));
});
// Route pour afficher le dashboard

// Route vers la page de login
router.get("/interface/login.html", (req, res) => {
  res.sendFile(path.join(__dirname, "../public/interface/login.html"));
});
router.get("/interface/users.html", (req, res) => {
  res.sendFile(path.join(__dirname, "../public/interface/users.html"));
});
router.get("/interface/groupes.html", (req, res) => {
  res.sendFile(path.join(__dirname, "../public/interface/groupes.html"));
});

router.get("/interface/activities.html", (req, res) => {
  res.sendFile(path.join(__dirname, "../public/interface/activities.html"));
});

router.get("/interface/cities.html", (req, res) => {
  res.sendFile(path.join(__dirname, "../public/interface/cities.html"));
});
router.get("/interface/activities.css", (req, res) => {
  res.sendFile(path.join(__dirname, "../public/interface/activities.css"));
  
});
router.get("/interface/dashboard.css", (req, res) => {
  res.sendFile(path.join(__dirname, "../public/interface/dashboard.css"));
  
});
router.get("/interface/groupes.css", (req, res) => {
  res.sendFile(path.join(__dirname, "../public/interface/groupes.css"));
  
});
router.get("/interface/users.css", (req, res) => {
  res.sendFile(path.join(__dirname, "../public/interface/users.css"));
  
});

module.exports = router;