const db = require('../config/db');

const postController = {
    // Get all posts with user info, images, and reaction count
    getAllPosts: async (req, res) => {
        try {
            const userId = req.query.userId; // Get the current user's ID from query params
            
            const [posts] = await db.query(`
                SELECT 
                    p.id_post,
                    p.contenu,
                    p.date_publication,
                    u.nom,
                    u.prenom,
                    u.photo_profil,
                    GROUP_CONCAT(i.chemin) AS images,
                    (
                        SELECT COUNT(*) 
                        FROM reactions r 
                        WHERE r.id_post = p.id_post
                    ) AS reaction_count,
                    EXISTS(
                        SELECT 1 
                        FROM reactions r2 
                        WHERE r2.id_post = p.id_post 
                        AND r2.id_utilisateur = ?
                    ) as has_reacted
                FROM posts p
                JOIN utilisateurs u ON p.id_auteur = u.id_utilisateur
                LEFT JOIN images i ON p.id_post = i.id_post
                GROUP BY p.id_post
                ORDER BY p.date_publication DESC
            `, [userId]);

            // Format the response
            const formattedPosts = posts.map(post => ({
                ...post,
                images: post.images ? post.images.split(',') : [],
                has_reacted: Boolean(post.has_reacted)
            }));

            res.json(formattedPosts);
        } catch (error) {
            console.error('Error getting posts:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    // Toggle reaction on a post
    toggleReaction: async (req, res) => {
        try {
            const { id_post } = req.params;
            const { id_utilisateur } = req.body;

            if (!id_utilisateur) {
                return res.status(400).json({ message: 'User ID is required' });
            }

            // Check if reaction exists
            const [existingReaction] = await db.query(
                'SELECT * FROM reactions WHERE id_post = ? AND id_utilisateur = ?',
                [id_post, id_utilisateur]
            );

            if (existingReaction.length > 0) {
                // Remove reaction
                await db.query(
                    'DELETE FROM reactions WHERE id_post = ? AND id_utilisateur = ?',
                    [id_post, id_utilisateur]
                );
            } else {
                // Add reaction
                await db.query(
                    'INSERT INTO reactions (id_post, id_utilisateur) VALUES (?, ?)',
                    [id_post, id_utilisateur]
                );
            }

            res.json({ success: true });
        } catch (error) {
            console.error('Error toggling reaction:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    }
};

module.exports = postController; 