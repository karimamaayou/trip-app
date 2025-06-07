const express = require('express');
const router = express.Router();
const tripController = require('../controllers/tripController');
const upload = require('../middlewares/upload');
const pool = require('../config/db');

// Get all trips
router.get('/allTrips', tripController.getAllTrips);

// Get paginated trips
router.get('/paginated', tripController.getPaginatedTrips);

// Get filtered trips
router.get('/filtered', tripController.getFilteredTrips);

// Get detailed trip information by ID
router.get('/details/:tripId', tripController.getTripDetailsById);

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
router.get('/user/:userId', tripController.getUserTrips);

// Get voyage participants
router.get('/:voyageId/participants', tripController.getVoyageParticipants);

// Get all trip participants including non-accepted ones
router.get('/:tripId/all-participants', tripController.getAllTripParticipants);

// Get trip details
router.get('/:tripId', tripController.getTripDetails);

// Create a new trip with images
router.post('/create', upload.array('images', 6), tripController.createTripWithImages);

// Add activity to trip
router.post('/:tripId/activities', tripController.addActivity);

// Join a trip
router.post('/:tripId/join', tripController.joinTrip);

// Get chat messages for a trip
router.get('/:tripId/messages', async (req, res) => {
  try {
    const [messages] = await pool.query(`
      SELECT 
        m.id_message,
        m.id_voyage,
        m.id_auteur,
        m.contenu,
        m.date_envoi,
        u.prenom,
        u.nom,
        u.photo_profil
      FROM messages_groupe m
      JOIN utilisateurs u ON m.id_auteur = u.id_utilisateur
      WHERE m.id_voyage = ?
      ORDER BY m.date_envoi ASC
    `, [req.params.tripId]);

    res.json(messages);
  } catch (error) {
    console.error('Error fetching messages:', error);
    res.status(500).json({ error: 'Failed to fetch messages' });
  }
});

// Remove a participant from a trip
router.delete('/trips/participants/:participantId', async (req, res) => {
  try {
    const participantId = req.params.participantId;

    // First check if the current user is an organizer
    const [currentUser] = await pool.query(
      'SELECT role FROM participations WHERE id_voyageur = ? AND role = "organisateur"',
      [req.user.id_utilisateur]
    );

    if (currentUser.length === 0) {
      return res.status(403).json({ message: 'Only organizers can remove participants' });
    }

    // Delete the participant
    const [result] = await pool.query(
      'DELETE FROM participations WHERE id_voyageur = ?',
      [participantId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Participant not found' });
    }

    res.json({ message: 'Participant removed successfully' });
  } catch (error) {
    console.error('Error removing participant:', error);
    res.status(500).json({ message: 'Error removing participant', error: error.message });
  }
});

// Leave a trip
router.post('/:tripId/leave', async (req, res) => {
  try {
    const tripId = req.params.tripId;
    const userId = req.body.userId;

    if (!userId) {
      return res.status(400).json({ message: 'User ID is required' });
    }

    // Check if user is the last organizer
    const [organizers] = await pool.query(
      'SELECT COUNT(*) as count FROM participations WHERE id_voyage = ? AND role = "organisateur"',
      [tripId]
    );

    const [userRole] = await pool.query(
      'SELECT role FROM participations WHERE id_voyage = ? AND id_voyageur = ?',
      [tripId, userId]
    );

    if (organizers[0].count === 1 && userRole[0]?.role === 'organisateur') {
      return res.status(400).json({ 
        message: 'Cannot leave the trip. You are the last organizer. Please assign another organizer or delete the trip.' 
      });
    }

    // Delete the participation record
    const [result] = await pool.query(
      'DELETE FROM participations WHERE id_voyage = ? AND id_voyageur = ?',
      [tripId, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Participation record not found' });
    }

    res.json({ message: 'Successfully left the trip' });
  } catch (error) {
    console.error('Error leaving trip:', error);
    res.status(500).json({ message: 'Error leaving trip', error: error.message });
  }
});

// Delete a trip
router.delete('/:tripId', tripController.deleteTrip);

// New route for removing a member
router.delete('/:tripId/remove-member/:memberId', tripController.removeMemberFromTrip);

// Check participation status for a friend
router.get('/:tripId/participation-status/:friendId', async (req, res) => {
  try {
    const { tripId, friendId } = req.params;
    
    const [participation] = await pool.query(
      `SELECT statut 
       FROM participations 
       WHERE id_voyage = ? AND id_voyageur = ?`,
      [tripId, friendId]
    );

    if (participation.length === 0) {
      return res.json({ status: 'not_invited' });
    }

    res.json({ status: participation[0].statut });
  } catch (error) {
    console.error('Error checking participation status:', error);
    res.status(500).json({ message: 'Error checking participation status', error: error.message });
  }
});

// Modify the invite endpoint to create a notification with trip_id
router.post('/:tripId/invite', async (req, res) => {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    
    const { tripId } = req.params;
    const { userId } = req.body;

    // Check if already invited
    const [existing] = await connection.query(
      'SELECT * FROM participations WHERE id_voyage = ? AND id_voyageur = ?',
      [tripId, userId]
    );

    if (existing.length > 0) {
      await connection.rollback();
      return res.status(400).json({ message: 'User already invited to this trip' });
    }

    // Add to participations table
    await connection.query(
      `INSERT INTO participations (id_voyage, id_voyageur, statut, role) 
       VALUES (?, ?, 'en_attente', 'voyageur')`,
      [tripId, userId]
    );

    // Get trip title for notification
    const [trip] = await connection.query(
      'SELECT titre FROM voyages WHERE id_voyage = ?',
      [tripId]
    );

    // Create notification with trip_id
    await connection.query(
      `INSERT INTO notifications (id_utilisateur, contenu, type, id_trip) 
       VALUES (?, ?, 'inv_voyage', ?)`,
      [userId, `Vous avez été invité à rejoindre le voyage "${trip[0].titre}"`, tripId]
    );

    await connection.commit();
    res.json({ message: 'Invitation sent successfully' });
  } catch (error) {
    await connection.rollback();
    console.error('Error sending invitation:', error);
    res.status(500).json({ message: 'Error sending invitation', error: error.message });
  } finally {
    connection.release();
  }
});

// Add endpoint to handle trip invitation response
router.post('/notifications/:notificationId/respond', async (req, res) => {
  const connection = await pool.getConnection();
  try {
    const { notificationId } = req.params;
    const { action } = req.body; // 'accept' or 'reject'
    const userId = req.query.userId;

    if (!userId) {
      return res.status(400).json({ message: 'User ID is required' });
    }

    if (!['accept', 'reject'].includes(action)) {
      return res.status(400).json({ message: 'Invalid action' });
    }

    await connection.beginTransaction();

    // Get notification details
    const [notification] = await connection.query(
      'SELECT * FROM notifications WHERE id_notification = ? AND id_utilisateur = ? AND type = ?',
      [notificationId, userId, 'inv_voyage']
    );

    if (notification.length === 0) {
      await connection.rollback();
      return res.status(404).json({ message: 'Notification not found' });
    }

    const tripId = notification[0].id_trip;

    if (action === 'accept') {
      // Update participation status to accepted
      await connection.query(
        'UPDATE participations SET statut = ? WHERE id_voyage = ? AND id_voyageur = ?',
        ['accepte', tripId, userId]
      );

      // Get trip title for notification
      const [trip] = await connection.query(
        'SELECT titre FROM voyages WHERE id_voyage = ?',
        [tripId]
      );

      // Create notification for trip organizer
      const [organizer] = await connection.query(
        'SELECT id_voyageur FROM participations WHERE id_voyage = ? AND role = "organisateur" LIMIT 1',
        [tripId]
      );

      if (organizer.length > 0) {
        const [user] = await connection.query(
          'SELECT CONCAT(prenom, " ", nom) as full_name FROM utilisateurs WHERE id_utilisateur = ?',
          [userId]
        );

        await connection.query(
          'INSERT INTO notifications (id_utilisateur, contenu, type, id_trip) VALUES (?, ?, ?, ?)',
          [organizer[0].id_voyageur, `${user[0].full_name} a accepté votre invitation au voyage "${trip[0].titre}"`, 'info', tripId]
        );
      }
    } else {
      // Remove participation record
      await connection.query(
        'DELETE FROM participations WHERE id_voyage = ? AND id_voyageur = ?',
        [tripId, userId]
      );
    }

    // Delete the notification
    await connection.query(
      'DELETE FROM notifications WHERE id_notification = ?',
      [notificationId]
    );

    await connection.commit();
    res.json({ 
      message: action === 'accept' ? 'Invitation acceptée' : 'Invitation refusée',
      status: action === 'accept' ? 'accepte' : 'refuse',
      deleted: true
    });
  } catch (error) {
    await connection.rollback();
    console.error('Error handling trip invitation:', error);
    res.status(500).json({ message: 'Error handling trip invitation', error: error.message });
  } finally {
    connection.release();
  }
});

// Add new endpoint to delete a notification
router.delete('/notifications/:notificationId', async (req, res) => {
  const connection = await pool.getConnection();
  try {
    const { notificationId } = req.params;
    const userId = req.query.userId;

    if (!userId) {
      return res.status(400).json({ message: 'User ID is required' });
    }

    await connection.beginTransaction();

    // Delete the notification
    const [result] = await connection.query(
      'DELETE FROM notifications WHERE id_notification = ? AND id_utilisateur = ?',
      [notificationId, userId]
    );

    if (result.affectedRows === 0) {
      await connection.rollback();
      return res.status(404).json({ message: 'Notification not found' });
    }

    await connection.commit();
    res.json({ message: 'Notification deleted successfully', deleted: true });
  } catch (error) {
    await connection.rollback();
    console.error('Error deleting notification:', error);
    res.status(500).json({ message: 'Error deleting notification', error: error.message });
  } finally {
    connection.release();
  }
});

module.exports = router;
