const express = require('express');
const router = express.Router();
const friendsController = require('../controllers/friendsController');
const pool = require('../config/db');

// Check if two users are friends
router.get('/check/:userId/:friendId', friendsController.checkFriendship);

// Check friendship and invitation status
router.get('/status/:userId/:friendId', friendsController.checkFriendshipAndInvitation);

// Send friend request
router.post('/request/:userId', friendsController.sendFriendRequest);

// Handle friend request response (accept/reject)
router.post('/request/:notificationId/respond', friendsController.handleFriendRequest);

// Get user's notifications
router.get('/notifications/:userId', friendsController.getUserNotifications);

// Get unread notifications count
router.get('/notifications/:userId/unread', friendsController.getUnreadNotificationsCount);

// Mark all user's notifications as read
router.put('/notifications/:userId/mark-read', friendsController.markNotificationsAsRead);

// Get user's friends list
router.get('/:userId', friendsController.getUserFriends);

// Toggle friendship (add/remove friend)
router.post('/:userId', friendsController.toggleFriendship);

router.get('/invitations/:userId', friendsController.getFriendInvitations);
router.get('/list/:userId', friendsController.getFriendsList);

// Handle friend invitation response (accept/reject)
router.post('/invitation/:senderId/respond', async (req, res) => {
  const connection = await pool.getConnection();
  try {
    const { senderId } = req.params;
    const { currentUserId } = req.query;
    const { action } = req.body;

    if (!currentUserId) {
      return res.status(400).json({ message: 'Current user ID is required' });
    }

    if (!['accept', 'reject'].includes(action)) {
      return res.status(400).json({ message: 'Invalid action' });
    }

    await connection.beginTransaction();

    if (action === 'accept') {
      // Update the friendship status to 'accpeter'
      await connection.query(
        'UPDATE amis SET statut = ? WHERE id_utilisateur = ? AND id_ami = ? AND statut = ?',
        ['accpeter', senderId, currentUserId, 'en_attente']
      );

      // Get current user's name for notification
      const [currentUser] = await connection.query(
        'SELECT CONCAT(prenom, " ", nom) as full_name FROM utilisateurs WHERE id_utilisateur = ?',
        [currentUserId]
      );

      // Create a notification for the sender
      await connection.query(
        'INSERT INTO notifications (id_utilisateur, contenu, type) VALUES (?, ?, ?)',
        [senderId, `${currentUser[0].full_name} a accepté votre demande d'ami`, 'info']
      );
    } else {
      // Delete the friend request
      await connection.query(
        'DELETE FROM amis WHERE id_utilisateur = ? AND id_ami = ? AND statut = ?',
        [senderId, currentUserId, 'en_attente']
      );
    }

    await connection.commit();
    res.json({ 
      message: action === 'accept' ? 'Demande d\'ami acceptée' : 'Demande d\'ami refusée',
      status: action === 'accept' ? 'accpeter' : 'rejected'
    });
  } catch (error) {
    await connection.rollback();
    console.error('Error handling friend invitation:', error);
    res.status(500).json({ message: 'Error handling friend invitation' });
  } finally {
    connection.release();
  }
});

// Remove friend
router.delete('/:userId/:friendId', async (req, res) => {
  try {
    const { userId, friendId } = req.params;
    
    // Delete both friendship records (bidirectional)
    await pool.query(
      'DELETE FROM amis WHERE (id_utilisateur = ? AND id_ami = ?) OR (id_utilisateur = ? AND id_ami = ?)',
      [userId, friendId, friendId, userId]
    );
    
    res.json({ message: 'Friend removed successfully' });
  } catch (error) {
    console.error('Error removing friend:', error);
    res.status(500).json({ message: 'Error removing friend' });
  }
});

module.exports = router; 