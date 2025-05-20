// Get pending requests for a trip
router.get('/:tripId/requests', async (req, res) => {
  try {
    console.log('Fetching requests for trip:', req.params.tripId); // Debug log
    const [requests] = await pool.query(
      `SELECT p.id_participation, p.id_voyageur, p.date_inscription, 
              u.nom, u.prenom, u.photo_profil
       FROM participations p
       JOIN utilisateurs u ON p.id_voyageur = u.id_utilisateur
       WHERE p.id_voyage = ? AND p.statut = 'en_attente'`,
      [req.params.tripId]
    );
    console.log('Found requests:', requests); // Debug log
    res.json(requests);
  } catch (error) {
    console.error('Error fetching pending requests:', error);
    res.status(500).json({ message: 'Error fetching pending requests', error: error.message });
  }
});

// Handle accept/reject request
router.post('/requests/:participationId/:action', async (req, res) => {
  const { participationId, action } = req.params;
  
  if (!['accept', 'reject'].includes(action)) {
    return res.status(400).json({ message: 'Invalid action' });
  }

  try {
    console.log(`Handling ${action} request for participation:`, participationId); // Debug log
    if (action === 'accept') {
      // Update status to 'accepte'
      await pool.query(
        'UPDATE participations SET statut = ? WHERE id_participation = ?',
        ['accepte', participationId]
      );
    } else {
      // Delete the participation record for rejection
      await pool.query(
        'DELETE FROM participations WHERE id_participation = ?',
        [participationId]
      );
    }
    
    res.json({ message: `Request ${action}ed successfully` });
  } catch (error) {
    console.error(`Error ${action}ing request:`, error);
    res.status(500).json({ message: `Error ${action}ing request`, error: error.message });
  }
});

// Get user's trips
router.get('/user/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;
    
    const query = `
      SELECT v.*, p.statut
      FROM voyages v
      JOIN participants p ON v.id_voyage = p.id_voyage
      WHERE p.id_voyageur = ?
      ORDER BY v.date_depart DESC
    `;
    
    const [trips] = await pool.query(query, [userId]);
    
    // For each trip, get additional data
    const tripsWithDetails = await Promise.all(trips.map(async (trip) => {
      // Get activities
      const [activities] = await pool.query(
        'SELECT a.* FROM activites a JOIN voyage_activites va ON a.id_activite = va.id_activite WHERE va.id_voyage = ?',
        [trip.id_voyage]
      );
      
      // Get images
      const [images] = await pool.query(
        'SELECT * FROM images WHERE id_voyage = ?',
        [trip.id_voyage]
      );
      
      // Get participants
      const [participants] = await pool.query(
        `SELECT v.*, p.statut, p.role 
         FROM voyageurs v 
         JOIN participants p ON v.id_voyageur = p.id_voyageur 
         WHERE p.id_voyage = ?`,
        [trip.id_voyage]
      );
      
      return {
        ...trip,
        activities,
        images,
        participants
      };
    }));
    
    res.json(tripsWithDetails);
  } catch (error) {
    console.error('Error fetching user trips:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}); 