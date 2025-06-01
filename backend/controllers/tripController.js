const Trip = require('../models/Trip');
const db = require('../config/db');

const tripController = {
    // Get paginated trips
    getPaginatedTrips: async (req, res) => {
        try {
            const page = parseInt(req.query.page) || 1;
            const limit = parseInt(req.query.limit) || 4;
            const offset = (page - 1) * limit;

            console.log(`Fetching trips - Page: ${page}, Limit: ${limit}, Offset: ${offset}`); // Debug log

            // First get total count
            const [countResult] = await db.query('SELECT COUNT(*) as total FROM voyages');
            const total = countResult[0].total;
            const totalPages = Math.ceil(total / limit);

            console.log(`Total trips: ${total}, Total pages: ${totalPages}`); // Debug log

            // Then get paginated trips
            const [trips] = await db.query(`
                SELECT v.*, 
                       vd.nom_ville as ville_depart,
                       va.nom_ville as ville_arrivee
                FROM voyages v
                LEFT JOIN ville vd ON v.id_ville_depart = vd.id_ville
                LEFT JOIN ville va ON v.id_ville_destination = va.id_ville
                ORDER BY v.date_depart DESC
                LIMIT ? OFFSET ?
            `, [limit, offset]);

            console.log(`Retrieved ${trips.length} trips for page ${page}`); // Debug log

            // Get participants, activities, and images for each trip
            for (let trip of trips) {
                const [participants] = await db.query(`
                    SELECT p.*, u.nom, u.prenom, u.email, u.photo_profil
                    FROM participations p
                    JOIN utilisateurs u ON p.id_voyageur = u.id_utilisateur
                    WHERE p.id_voyage = ?
                `, [trip.id_voyage]);

                const [activities] = await db.query(`
                    SELECT a.*
                    FROM activities a
                    JOIN voyage_activities va ON a.id_activity = va.id_activity
                    WHERE va.id_voyage = ?
                `, [trip.id_voyage]);

                const [images] = await db.query(`
                    SELECT chemin
                    FROM images
                    WHERE id_voyage = ?
                `, [trip.id_voyage]);

                // Add the correct path prefix to images
                trip.images = images.map(img => ({
                    ...img,
                    chemin: `/uploads/trip_images/${img.chemin}`
                }));

                trip.participants = participants;
                trip.activities = activities;
            }

            res.json({
                trips,
                pagination: {
                    currentPage: page,
                    totalPages: totalPages,
                    totalItems: total,
                    itemsPerPage: limit,
                    hasNextPage: page < totalPages
                }
            });
        } catch (error) {
            console.error('Error getting paginated trips:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    // Get all trips
    getAllTrips: async (req, res) => {
        try {
            const trips = await Trip.getAllTrips();
            res.json(trips);
        } catch (error) {
            console.error('Error getting all trips:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    // Get trip details
    getTripDetails: async (req, res) => {
        try {
            const { tripId } = req.params;
            const trip = await Trip.getTripDetails(tripId);
            
            if (!trip) {
                return res.status(404).json({ message: 'Trip not found' });
            }

            res.json(trip);
        } catch (error) {
            console.error('Error getting trip details:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    // Create a new trip
    createTrip: async (req, res) => {
        try {
            const tripData = req.body;
            const tripId = await Trip.createTrip(tripData);
            
            res.status(201).json({
                message: 'Trip created successfully',
                tripId
            });
        } catch (error) {
            console.error('Error creating trip:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    // Add activity to trip
    addActivity: async (req, res) => {
        try {
            const { tripId } = req.params;
            const { activityId } = req.body;

            await Trip.addActivityToTrip(tripId, activityId);
            
            res.json({ message: 'Activity added to trip successfully' });
        } catch (error) {
            console.error('Error adding activity to trip:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    // Join a trip
    joinTrip: async (req, res) => {
        try {
            const { tripId } = req.params;
            const { userId, role } = req.body;

            await Trip.joinTrip(tripId, userId, role);
            
            res.json({ message: 'Successfully joined the trip' });
        } catch (error) {
            console.error('Error joining trip:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    // Get user's trips
    getUserTrips: async (req, res) => {
        try {
            const { userId } = req.params;
            const trips = await Trip.getUserTrips(userId);
            res.json(trips);
        } catch (error) {
            console.error('Error getting user trips:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    // Get detailed trip information by ID
    getTripDetailsById: async (req, res) => {
        try {
            const { tripId } = req.params;
            const trip = await Trip.getTripDetailsById(tripId);
            
            if (!trip) {
                return res.status(404).json({ message: 'Trip not found' });
            }

            res.json(trip);
        } catch (error) {
            console.error('Error getting trip details:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    // Get voyage participants
    getVoyageParticipants: async (req, res) => {
        try {
            const { voyageId } = req.params;
            const participants = await Trip.getVoyageParticipants(voyageId);
            
            if (!participants || participants.length === 0) {
                return res.status(404).json({ message: 'No participants found for this voyage' });
            }

            res.json(participants);
        } catch (error) {
            console.error('Error getting voyage participants:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    // Create a new trip with images
    createTripWithImages: async (req, res) => {
        try {
            console.log('Request body:', req.body); // Debug log entire request body
            
            const {
                titre,
                description,
                date_depart,
                date_retour,
                capacite_max,
                id_ville_depart,
                id_ville_destination,
                userId,
                activites ,// Changed from destructuring to get activities directly
                 latitude,
                longitude
            } = req.body;
              // Debug log for coordinates
            console.log('Coordinates received:', {
                latitude,
                longitude,
                type: {
                    latitude: typeof latitude,
                    longitude: typeof longitude
                }
            });

            // Get activities from request body and ensure they are integers
            let parsedActivities = [];
            if (activites) {
                parsedActivities = Array.isArray(activites) 
                    ? activites.map(id => parseInt(id))
                    : [parseInt(activites)].filter(id => !isNaN(id));
            }
            
            console.log('Parsed activities:', parsedActivities); // Debug log parsed activities

            // Start transaction
            const connection = await db.getConnection();
            await connection.beginTransaction();

            try {
                // Create the trip
                const [result] = await connection.query(
                    `INSERT INTO voyages (
                        titre, description, date_depart, date_retour,
                        capacite_max, id_ville_depart, id_ville_destination, budget,latitude, longitude
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
                    [titre, description, date_depart, date_retour, capacite_max, id_ville_depart, id_ville_destination, req.body.budget, req.body.latitude,
                        req.body.longitude]
                );

                const tripId = result.insertId;
                console.log('Created trip with ID:', tripId); // Debug log trip ID

                // Add activities
                if (parsedActivities && parsedActivities.length > 0) {
                    const activityValues = parsedActivities.map(activityId => [tripId, activityId]);
                    console.log('Activity values to be inserted:', activityValues); // Debug log
                    
                    const [activityResult] = await connection.query(
                        'INSERT INTO voyage_activities (id_voyage, id_activity) VALUES ?',
                        [activityValues]
                    );
                    console.log('Activity insertion result:', activityResult); // Debug log
                } else {
                    console.log('No activities to insert'); // Debug log
                }

                // Add images
                if (req.files && req.files.length > 0) {
                    const imageValues = req.files.map(file => [
                        file.path.replace(/\\/g, '/').replace(/^.*[\\\/]/, '/'), // Normalize path and keep only the relative path
                        tripId,
                        null // id_post is null for trip images
                    ]);
                    
                    // Log the image values for debugging
                    console.log('Image values to be inserted:', imageValues);
                    
                    await connection.query(
                        'INSERT INTO images (chemin, id_voyage, id_post) VALUES ?',
                        [imageValues]
                    );
                }

                // Add creator as organizer
                await connection.query(
                    `INSERT INTO participations (
                        id_voyage, id_voyageur, role, statut
                    ) VALUES (?, ?, 'organisateur', 'accepte')`,
                    [tripId, userId]
                );

                await connection.commit();
                res.status(201).json({
                    message: 'Trip created successfully',
                    tripId
                });
            } catch (error) {
                await connection.rollback();
                throw error;
            } finally {
                connection.release();
            }
        } catch (error) {
            console.error('Error creating trip:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    // Get filtered and paginated trips
    getFilteredTrips: async (req, res) => {
        try {
            const page = parseInt(req.query.page) || 1;
            const limit = parseInt(req.query.limit) || 4;
            const offset = (page - 1) * limit;
            
            console.log('Filtered trips request:', {
                page,
                limit,
                offset,
                query: req.query
            });
            
            // Get filter parameters
            const { budget, depart, destination, activities, search } = req.query;
            
            // Build the base query
            let query = `
                SELECT DISTINCT v.*, 
                       vd.nom_ville as ville_depart,
                       va.nom_ville as ville_arrivee
                FROM voyages v
                LEFT JOIN ville vd ON v.id_ville_depart = vd.id_ville
                LEFT JOIN ville va ON v.id_ville_destination = va.id_ville
                LEFT JOIN voyage_activities va2 ON v.id_voyage = va2.id_voyage
                LEFT JOIN activities a ON va2.id_activity = a.id_activity
                WHERE 1=1
            `;
            
            const queryParams = [];
            
            // Add search condition if provided
            if (search) {
                query += ` AND (
                    v.titre LIKE ? OR 
                    v.description LIKE ? OR 
                    vd.nom_ville LIKE ? OR 
                    va.nom_ville LIKE ?
                )`;
                const searchParam = `%${search}%`;
                queryParams.push(searchParam, searchParam, searchParam, searchParam);
            }
            
            // Add budget filter if provided
            if (budget) {
                query += ` AND v.budget <= ?`;
                queryParams.push(budget);
            }
            
            // Add departure city filter if provided
            if (depart) {
                query += ` AND vd.nom_ville = ?`;
                queryParams.push(depart);
            }
            
            // Add destination city filter if provided
            if (destination) {
                query += ` AND va.nom_ville = ?`;
                queryParams.push(destination);
            }
            
            // Add activities filter if provided
            if (activities) {
                const activityList = activities.split(',');
                query += ` AND a.nom_activity IN (${activityList.map(() => '?').join(',')})`;
                queryParams.push(...activityList);
            }
            
            // Get total count for pagination
            const countQuery = query.replace('DISTINCT v.*, vd.nom_ville as ville_depart, va.nom_ville as ville_arrivee', 'COUNT(DISTINCT v.id_voyage) as total');
            console.log('Count query:', countQuery);
            console.log('Count params:', queryParams);
            
            const [countResult] = await db.query(countQuery, queryParams);
            const total = countResult[0].total;
            const totalPages = Math.ceil(total / limit);
            
            console.log('Pagination info:', {
                total,
                totalPages,
                currentPage: page,
                hasNextPage: page < totalPages
            });
            
            // Add pagination
            query += ` GROUP BY v.id_voyage ORDER BY v.date_depart DESC LIMIT ? OFFSET ?`;
            queryParams.push(limit, offset);
            
            console.log('Final query:', query);
            console.log('Final params:', queryParams);
            
            // Execute the query
            const [trips] = await db.query(query, queryParams);
            
            console.log(`Retrieved ${trips.length} trips for page ${page}`);
            
            // Get additional data for each trip
            for (let trip of trips) {
                const [participants] = await db.query(`
                    SELECT p.*, u.nom, u.prenom, u.email, u.photo_profil
                    FROM participations p
                    JOIN utilisateurs u ON p.id_voyageur = u.id_utilisateur
                    WHERE p.id_voyage = ?
                `, [trip.id_voyage]);

                const [activities] = await db.query(`
                    SELECT a.*
                    FROM activities a
                    JOIN voyage_activities va ON a.id_activity = va.id_activity
                    WHERE va.id_voyage = ?
                `, [trip.id_voyage]);

                const [images] = await db.query(`
                    SELECT chemin
                    FROM images
                    WHERE id_voyage = ?
                `, [trip.id_voyage]);

                trip.images = images.map(img => ({
                    ...img,
                    chemin: `/uploads/trip_images/${img.chemin}`
                }));

                trip.participants = participants;
                trip.activities = activities;
            }

            const response = {
                trips,
                pagination: {
                    currentPage: page,
                    totalPages: totalPages,
                    totalItems: total,
                    itemsPerPage: limit,
                    hasNextPage: page < totalPages
                }
            };

            console.log('Sending response:', response.pagination);
            res.json(response);
        } catch (error) {
            console.error('Error getting filtered trips:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },

    // Delete a trip
    deleteTrip: async (req, res) => {
        const connection = await db.getConnection();
        try {
            await connection.beginTransaction();
            const { tripId } = req.params;

            // Optional: Add authorization check here to ensure only the organizer can delete
            // You would need to fetch participant roles for the trip and check if the current user is the organizer.
            // For now, assuming authorization is handled elsewhere or will be added later.

            // Delete related data first (e.g., participations, activities, images)
            // These queries assume foreign key constraints with CASCADE DELETE are NOT set up.
            // If CASCADE DELETE is set up in your database schema, you might only need to delete the trip itself.
            await connection.query('DELETE FROM participations WHERE id_voyage = ?', [tripId]);
            await connection.query('DELETE FROM voyage_activities WHERE id_voyage = ?', [tripId]);
            await connection.query('DELETE FROM images WHERE id_voyage = ?', [tripId]);

            // Delete the trip
            const [result] = await connection.query('DELETE FROM voyages WHERE id_voyage = ?', [tripId]);

            if (result.affectedRows === 0) {
                 await connection.rollback();
                 return res.status(404).json({ message: 'Voyage non trouvé.' });
            }

            await connection.commit();
            res.status(200).json({ message: 'Voyage supprimé avec succès.' });

        } catch (error) {
            await connection.rollback();
            console.error('Error deleting trip:', error);
            res.status(500).json({ message: 'Erreur interne du serveur lors de la suppression du voyage.' });
        } finally {
            connection.release();
        }
    },

    // Remove a member from a trip (Organizer action)
    removeMemberFromTrip: async (req, res) => {
        const tripId = req.params.tripId;
        const memberId = req.params.memberId;

        // Basic validation
        if (!tripId || !memberId) {
            return res.status(400).json({ message: 'Trip ID and Member ID are required.' });
        }

        let connection;
        try {
            connection = await db.getConnection();
            await connection.beginTransaction();

            // Check if the member exists in the participation table for this trip
            const [participation] = await connection.query(
                'SELECT * FROM participations WHERE id_voyage = ? AND id_voyageur = ?',
                [tripId, memberId]
            );

            if (participation.length === 0) {
                await connection.rollback();
                return res.status(404).json({ message: 'Member not found in this trip.' });
            }

            // Prevent organizer from excluding themselves
            // You might want to add a check here to ensure the requesting user is the organizer
            // For simplicity, we'll rely on the frontend sending the correct info for now
            // but a backend check is recommended for security.

            // Delete the participation record
            await connection.query(
                'DELETE FROM participations WHERE id_voyage = ? AND id_voyageur = ?',
                [tripId, memberId]
            );

            await connection.commit();
            res.status(200).json({ message: 'Member removed successfully.' });

        } catch (error) {
            if (connection) {
                await connection.rollback();
            }
            console.error('Error removing member from trip:', error);
            res.status(500).json({ message: 'An error occurred while removing the member.', error: error.message });
        } finally {
            if (connection) {
                connection.release();
            }
        }
    },

    // Leave a trip (User action)
    leaveTrip: async (req, res) => {
        // ... existing code ...
    }
};

module.exports = tripController;
