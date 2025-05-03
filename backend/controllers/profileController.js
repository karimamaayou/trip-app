const Profile = require('../models/Profile');
const path = require('path');

const profileController = {
    // Get user profile
    getUserProfile: async (req, res) => {
        try {
            const { userId } = req.params;
            const profile = await Profile.getUserProfile(userId);
            
            if (!profile) {
                return res.status(404).json({ message: 'User profile not found' });
            }

            // If there's a photo_profil, convert it to a full URL
            if (profile.photo_profil) {
                profile.photo_profil = `/uploads/profile_pictures/${profile.photo_profil}`;
            }

            res.json(profile);
        } catch (error) {
            console.error('Error getting user profile:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    // Update user profile
    updateUserProfile: async (req, res) => {
        try {
            const { userId } = req.params;
            const { nom, prenom, email } = req.body;

            // Validate required fields
            if (!nom || !prenom || !email) {
                return res.status(400).json({ message: 'Missing required fields' });
            }

            // Handle profile picture
            let photo_profil = null;
            if (req.files && req.files.profile_image) {
                photo_profil = req.files.profile_image[0].filename;
            }

            const profileData = {
                nom,
                prenom,
                email,
                photo_profil
            };

            await Profile.updateUserProfile(userId, profileData);
            
            res.json({ 
                message: 'Profile updated successfully',
                profile: {
                    ...profileData,
                    photo_profil: photo_profil ? `/uploads/profile_pictures/${photo_profil}` : null
                }
            });
        } catch (error) {
            console.error('Error updating user profile:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    }
};

module.exports = profileController;
