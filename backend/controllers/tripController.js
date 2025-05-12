const Trip = require('../models/Trip');
const db = require('../config/db');

const tripController = {
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
                activites // Changed from destructuring to get activities directly
            } = req.body;

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
                        capacite_max, id_ville_depart, id_ville_destination, budget
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
                    [titre, description, date_depart, date_retour, capacite_max, id_ville_depart, id_ville_destination, req.body.budget]
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
    }
};

module.exports = tripController;
