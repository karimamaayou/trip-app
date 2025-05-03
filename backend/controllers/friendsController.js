const Friends = require('../models/Friends');

const friendsController = {
    // Get user's friends list
    getUserFriends: async (req, res) => {
        try {
            const { userId } = req.params;
            const friends = await Friends.getUserFriends(userId);
            
            res.json(friends);
        } catch (error) {
            console.error('Error getting user friends:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    }
};

module.exports = friendsController; 