const db = require("../config/db");
const { login } = require("../controllers/dashbordController");

const User = {
  getAllVoyageurs: async () => {
    const query = `
      SELECT id_utilisateur, nom, prenom, email, date_inscription, role
      FROM utilisateurs where _caution = 1  
    `;
    const [rows] = await db.query(query);
    return rows;
  }, 
  getAllGroupesVoyageurs: async () => {
    const query = `
    SELECT  
        v.id_voyage,
        v.titre,
        v.description,
        v.budget,
        v.date_depart,
        v.date_retour,
        vd.nom_ville AS ville_depart,
        va.nom_ville AS ville_destination,
        u.nom AS nom_voyageur,
        u.prenom AS prenom_voyageur,
        p.role AS role_voyageur
    FROM 
        participations p
    JOIN 
        voyages v ON p.id_voyage = v.id_voyage
    JOIN 
        utilisateurs u ON p.id_voyageur = u.id_utilisateur
    JOIN 
        ville vd ON v.id_ville_depart = vd.id_ville
    JOIN 
        ville va ON v.id_ville_destination = va.id_ville
  `;
 
    const [rows] = await db.query(query);

    // Regrouper les voyageurs par voyage
    const voyagesMap = {};

    for (const row of rows) {
      const {
        id_voyage,
        titre,
        description,
        budget,
        date_depart,
        date_retour,
        ville_depart,
        ville_destination,
        nom_voyageur,
        prenom_voyageur,
        role_voyageur,
      } = row;

      if (!voyagesMap[id_voyage]) {
        voyagesMap[id_voyage] = {
          id_voyage,
          titre,
          description,
          budget,
          date_depart,
          date_retour,
          ville_depart,
          ville_destination,
          voyageurs: [],
        };
      }

      voyagesMap[id_voyage].voyageurs.push({
        nom: nom_voyageur,
        prenom: prenom_voyageur,
        role: role_voyageur,
      });
    }

    return Object.values(voyagesMap);
  },

  getAllstatique: async () => {
    const query = `
SELECT
    (SELECT COUNT(*) FROM utilisateurs) AS total_utilisateurs,
    (SELECT COUNT(*) FROM posts) AS total_posts,
    (SELECT COUNT(*) FROM voyages) AS total_voyages,
    (SELECT COUNT(*) FROM voyages) AS total_groupes;
    `;
    const [rows] = await db.query(query);
    return rows;
  },

  getAllshort: async () => {
    const query = `
SELECT COUNT(vo.id_voyage) AS nombre_voyages, v.nom_ville
FROM voyages vo
JOIN ville v ON vo.id_ville_destination = v.id_ville
GROUP BY v.nom_ville
ORDER BY nombre_voyages DESC;

    `;
    const [rows] = await db.query(query);
    return rows;
  },

  login: async (email, password) => {
    const query = `
      SELECT id_utilisateur, email, mot_de_passe, role
      FROM utilisateurs
      WHERE email = ? AND role = 'admin'
    `;
    const [rows] = await db.query(query, [email]);
    return rows[0];
  },

  getUsersByMonth: async () => {
    const query = `
      WITH RECURSIVE months AS (
        SELECT 1 as month
        UNION ALL
        SELECT month + 1
        FROM months
        WHERE month < 12
      )
      SELECT 
        m.month,
        COALESCE(COUNT(u.id_utilisateur), 0) as count
      FROM months m
      LEFT JOIN utilisateurs u ON 
        MONTH(u.date_inscription) = m.month 
        AND YEAR(u.date_inscription) = YEAR(CURDATE())
      GROUP BY m.month
      ORDER BY m.month
    `;
    const [rows] = await db.query(query);
    return rows;
  },

  addVille: async (villeData) => {
    const query = `
  INSERT INTO ville (nom_ville) VALUES (?);
    `;
    const [result] = await db.query(query, [villeData.nom_ville]);
    return result.insertId;
  },

  checkVilleUsage: async (villeId) => {
    const query = `
      SELECT COUNT(*) as count
      FROM voyages
      WHERE id_ville_depart = ? OR id_ville_destination = ?
    `;
    const [rows] = await db.query(query, [villeId, villeId]);
    return rows[0].count > 0;
  },

  deleteVille: async (villeId) => {
    // Vérifier d'abord si la ville est utilisée
    const isUsed = await User.checkVilleUsage(villeId);
    if (isUsed) {
      throw new Error(
        "Cette ville est utilisée dans des voyages et ne peut pas être supprimée"
      );
    }

    const query = `
      DELETE FROM ville 
      WHERE id_ville = ?
    `;
    const [result] = await db.query(query, [villeId]);
    return result.affectedRows > 0;
  },

  getAllVilles: async () => {
    const query = `
      SELECT id_ville, nom_ville
      FROM ville
      ORDER BY nom_ville ASC
    `;
    const [rows] = await db.query(query);
    return rows;
  },

  checkVilleExists: async (nom_ville) => {
    const query = `
      SELECT id_ville
      FROM ville
      WHERE nom_ville = ?
    `;
    const [rows] = await db.query(query, [nom_ville]);
    return rows.length > 0;
  },
  updateCaution: async (userId) => {
    const query = `
    UPDATE utilisateurs
    SET _caution = 0
    WHERE id_utilisateur = ?;
  `;
    const [rows] = await db.query(query, [userId]);
    return rows;
  },

  // Activity related functions
  getAllActivities: async () => {
    const query = `
    SELECT id_activity, nom_activity 
    FROM activities 
    ORDER BY nom_activity ASC
  `;
    const [rows] = await db.query(query);
    return rows;
  },

  addActivity: async (nom_activity) => {
    const query = `
    INSERT INTO activities (nom_activity) 
    VALUES (?)
  `;
    const [result] = await db.query(query, [nom_activity]);
    return result.insertId;
  },

  deleteActivity: async (id_activity) => {
    const query = `
    DELETE FROM activities 
    WHERE id_activity = ?
  `;
    const [result] = await db.query(query, [id_activity]);
    return result.affectedRows > 0;
  },
};

module.exports = User;
