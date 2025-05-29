const db = require('../config/db');

const friendsController = {
    // Get user's friends list
    getUserFriends: async (req, res) => {
        try {
            const { userId } = req.params;
            const [friends] = await db.query(`
                SELECT 
                    u.id_utilisateur as id_ami,
                    u.nom,
                    u.prenom,
                    u.email,
                    u.photo_profil,
                    u.role,
                    u.date_inscription
                FROM amis a
                JOIN utilisateurs u ON a.id_ami = u.id_utilisateur
                WHERE a.id_utilisateur = ? AND a.statut = 'accpeter'
                ORDER BY u.nom, u.prenom
            `, [userId]);

            // Convert photo_profil paths to full URLs
            friends.forEach(friend => {
                if (friend.photo_profil) {
                    friend.photo_profil = `${friend.photo_profil}`;
                }
            });

            res.json(friends);
        } catch (error) {
            console.error('Error getting user friends:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    // Toggle friendship (add/remove friend)
    toggleFriendship: async (req, res) => {
        try {
            const { userId } = req.params; // ID of the user to add/remove as friend
            const currentUserId = req.user.id_utilisateur; // ID of the current user

            // Check if friendship already exists
            const [existingFriendship] = await db.query(
                'SELECT * FROM amis WHERE (id_utilisateur = ? AND id_ami = ?) OR (id_utilisateur = ? AND id_ami = ?)',
                [currentUserId, userId, userId, currentUserId]
            );

            if (existingFriendship.length > 0) {
                // Remove friendship
                await db.query(
                    'DELETE FROM amis WHERE (id_utilisateur = ? AND id_ami = ?) OR (id_utilisateur = ? AND id_ami = ?)',
                    [currentUserId, userId, userId, currentUserId]
                );
                res.json({ message: 'Friend removed successfully', isFriend: false });
            } else {
                // Add friendship (bidirectional)
                await db.query(
                    'INSERT INTO amis (id_utilisateur, id_ami) VALUES (?, ?), (?, ?)',
                    [currentUserId, userId, userId, currentUserId]
                );
                res.json({ message: 'Friend added successfully', isFriend: true });
            }
        } catch (error) {
            console.error('Error toggling friendship:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    // Check if two users are friends
    checkFriendship: async (req, res) => {
        try {
            const { userId, friendId } = req.params;
            
            const [friendship] = await db.query(`
                SELECT * FROM amis 
                WHERE (id_utilisateur = ? AND id_ami = ?) 
                OR (id_utilisateur = ? AND id_ami = ?)
            `, [userId, friendId, friendId, userId]);

            res.json({ isFriend: friendship.length > 0 });
        } catch (error) {
            console.error('Error checking friendship:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    // Check friendship and invitation status
    checkFriendshipAndInvitation: async (req, res) => {
        try {
            const { userId, friendId } = req.params;
            
            // Check friendship status
            const [friendship] = await db.query(`
                SELECT statut 
                FROM amis 
                WHERE (id_utilisateur = ? AND id_ami = ?) 
                OR (id_utilisateur = ? AND id_ami = ?)
            `, [userId, friendId, friendId, userId]);

            // Check invitation status
            const [invitation] = await db.query(`
                SELECT statut 
                FROM amis 
                WHERE id_utilisateur = ? AND id_ami = ? AND statut = 'en_attente'
            `, [userId, friendId]);

            let status = 'not_friend';
            if (friendship.length > 0) {
                status = friendship[0].statut === 'accpeter' ? 'friend' : 'pending';
            } else if (invitation.length > 0) {
                status = 'invitation_sent';
            }

            res.json({ 
                status,
                isFriend: status === 'friend',
                isPending: status === 'pending',
                isInvitationSent: status === 'invitation_sent'
            });
        } catch (error) {
            console.error('Error checking friendship and invitation status:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    // Send friend request
    sendFriendRequest: async (req, res) => {
        const connection = await db.getConnection();
        try {
            const { userId } = req.params; // ID of the user to send request to
            const currentUserId = req.query.currentUserId; // Get current user ID from query params

            if (!currentUserId) {
                return res.status(400).json({ message: 'Current user ID is required' });
            }

            // Check if any friendship or request already exists
            const [existing] = await connection.query(
                'SELECT * FROM amis WHERE (id_utilisateur = ? AND id_ami = ?) OR (id_utilisateur = ? AND id_ami = ?)',
                [currentUserId, userId, userId, currentUserId]
            );

            if (existing.length > 0) {
                return res.status(400).json({ 
                    message: 'Friendship or request already exists',
                    status: existing[0].statut
                });
            }

            // Start transaction
            await connection.beginTransaction();

            try {
                // Add friend request
                await connection.query(
                    'INSERT INTO amis (id_utilisateur, id_ami, statut) VALUES (?, ?, ?)',
                    [currentUserId, userId, 'en_attente']
                );

                // Get sender's name for notification
                const [sender] = await connection.query(
                    'SELECT CONCAT(prenom, " ", nom) as full_name FROM utilisateurs WHERE id_utilisateur = ?',
                    [currentUserId]
                );

                // Create notification
                await connection.query(
                    'INSERT INTO notifications (id_utilisateur, contenu, type) VALUES (?, ?, ?)',
                    [userId, `${sender[0].full_name} vous a envoyé une demande d'ami`, 'inv_ami']
                );

                await connection.commit();
                res.json({ 
                    message: 'Friend request sent successfully',
                    status: 'invitation_sent'
                });
            } catch (error) {
                await connection.rollback();
                throw error;
            }
        } catch (error) {
            console.error('Error sending friend request:', error);
            res.status(500).json({ message: 'Internal server error' });
        } finally {
            connection.release();
        }
    },

    // Handle friend request response (accept/reject)
    handleFriendRequest: async (req, res) => {
        const connection = await db.getConnection();
        try {
            const { notificationId } = req.params;
            const { action } = req.body; // 'accept' or 'reject'
            const currentUserId = req.query.currentUserId;

            if (!currentUserId) {
                return res.status(400).json({ message: 'Current user ID is required' });
            }

            // Get notification details
            const [notification] = await connection.query(
                'SELECT * FROM notifications WHERE id_notification = ? AND id_utilisateur = ? AND type = ?',
                [notificationId, currentUserId, 'inv_ami']
            );

            if (notification.length === 0) {
                return res.status(404).json({ message: 'Notification not found' });
            }

            // Extract sender's name from notification content
            const senderName = notification[0].contenu.split(' vous a envoyé')[0];

            // Get sender's ID
            const [sender] = await connection.query(
                'SELECT id_utilisateur FROM utilisateurs WHERE CONCAT(prenom, " ", nom) = ?',
                [senderName]
            );

            if (sender.length === 0) {
                return res.status(404).json({ message: 'Sender not found' });
            }

            const senderId = sender[0].id_utilisateur;

            await connection.beginTransaction();

            try {
                if (action === 'accept') {
                    // Update friendship status to accepted
                    await connection.query(
                        'UPDATE amis SET statut = ? WHERE id_utilisateur = ? AND id_ami = ?',
                        ['accpeter', senderId, currentUserId]
                    );

                    // Create notification for sender
                    await connection.query(
                        'INSERT INTO notifications (id_utilisateur, contenu, type) VALUES (?, ?, ?)',
                        [senderId, `${notification[0].contenu.split(' vous a envoyé')[0]} a accepté votre demande d'ami`, 'info']
                    );
                } else {
                    // Remove friendship request
                    await connection.query(
                        'DELETE FROM amis WHERE id_utilisateur = ? AND id_ami = ?',
                        [senderId, currentUserId]
                    );

                    // Create notification for sender
                    await connection.query(
                        'INSERT INTO notifications (id_utilisateur, contenu, type) VALUES (?, ?, ?)',
                        [senderId, `${notification[0].contenu.split(' vous a envoyé')[0]} a refusé votre demande d'ami`, 'info']
                    );
                }

                // Mark notification as read
                await connection.query(
                    'UPDATE notifications SET lue = 1 WHERE id_notification = ?',
                    [notificationId]
                );

                await connection.commit();
                res.json({ 
                    message: action === 'accept' ? 'Friend request accepted' : 'Friend request rejected',
                    status: action === 'accept' ? 'accepted' : 'rejected'
                });
            } catch (error) {
                await connection.rollback();
                throw error;
            }
        } catch (error) {
            console.error('Error handling friend request:', error);
            res.status(500).json({ message: 'Internal server error' });
        } finally {
            connection.release();
        }
    },

    // Get user's notifications
    getUserNotifications: async (req, res) => {
        try {
            const { userId } = req.params;
            
            const [notifications] = await db.query(`
                SELECT 
                    n.*,
                    CASE 
                        WHEN n.type = 'inv_ami' THEN 1
                        ELSE 0
                    END as has_action
                FROM notifications n
                WHERE n.id_utilisateur = ?
                ORDER BY n.date_notification DESC
            `, [userId]);

            // Convert MySQL tinyint to boolean for lue field
            const formattedNotifications = notifications.map(notification => ({
                ...notification,
                lue: notification.lue === 1,
                has_action: notification.has_action === 1
            }));

            res.json(formattedNotifications);
        } catch (error) {
            console.error('Error getting notifications:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    // Get unread notifications count
    getUnreadNotificationsCount: async (req, res) => {
        try {
            const { userId } = req.params;
            
            const [result] = await db.query(
                'SELECT COUNT(*) as count FROM notifications WHERE id_utilisateur = ? AND lue = 0',
                [userId]
            );

            res.json({ count: result[0].count });
        } catch (error) {
            console.error('Error getting unread notifications count:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    // Mark all user's notifications as read
    markNotificationsAsRead: async (req, res) => {
        try {
            const { userId } = req.params;
            
            await db.query(
                'UPDATE notifications SET lue = 1 WHERE id_utilisateur = ? AND lue = 0',
                [userId]
            );

            res.status(200).json({ message: 'Notifications marked as read' });
        } catch (error) {
            console.error('Error marking notifications as read:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    getFriendInvitations: async (req, res) => {
        const { userId } = req.params;
        
        try {
            const [invitations] = await db.query(`
                SELECT 
                    u.id_utilisateur,
                    u.prenom,
                    u.nom,
                    u.photo_profil,
                    u.role
                FROM amis a
                JOIN utilisateurs u ON a.id_utilisateur = u.id_utilisateur
                WHERE a.id_ami = ? AND a.statut = 'en_attente'
                ORDER BY u.nom, u.prenom
            `, [userId]);

            res.json(invitations);
        } catch (error) {
            console.error('Error fetching friend invitations:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    getFriendsList: async (req, res) => {
        const { userId } = req.params;
        
        try {
            const [friends] = await db.query(`
                SELECT u.id_utilisateur, u.prenom, u.nom, u.photo_profil, u.role
                FROM amis a
                JOIN utilisateurs u ON (
                    CASE 
                        WHEN a.id_utilisateur = ? THEN a.id_ami = u.id_utilisateur
                        ELSE a.id_utilisateur = u.id_utilisateur
                    END
                )
                WHERE (a.id_utilisateur = ? OR a.id_ami = ?)
                AND a.statut = 'accpeter'
            `, [userId, userId, userId]);

            res.json(friends);
        } catch (error) {
            console.error('Error fetching friends list:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    respondToInvitation: async (req, res) => {
        const { senderId } = req.params;
        const { currentUserId } = req.query;
        const { action } = req.body;

        if (!['accept', 'reject'].includes(action)) {
            return res.status(400).json({ message: 'Invalid action' });
        }

        const connection = await db.getConnection();
        try {
            await connection.beginTransaction();

            if (action === 'accept') {
                // Update the friendship status to 'accpeter'
                await connection.query(
                    'UPDATE amis SET statut = "accpeter" WHERE id_utilisateur = ? AND id_ami = ? AND statut = "en_attente"',
                    [senderId, currentUserId]
                );

                // Get current user's name for notification
                const [currentUser] = await connection.query(
                    'SELECT CONCAT(prenom, " ", nom) as full_name FROM utilisateurs WHERE id_utilisateur = ?',
                    [currentUserId]
                );

                // Create a notification for the sender
                await connection.query(
                    'INSERT INTO notifications (id_utilisateur, contenu, type, lue) VALUES (?, ?, ?, 0)',
                    [senderId, `${currentUser[0].full_name} a accepté votre demande d'ami`, 'info']
                );
            } else {
                // Delete the friend request
                await connection.query(
                    'DELETE FROM amis WHERE id_utilisateur = ? AND id_ami = ? AND statut = "en_attente"',
                    [senderId, currentUserId]
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
            res.status(500).json({ message: 'Internal server error' });
        } finally {
            connection.release();
        }
    }
};

module.exports = friendsController; 