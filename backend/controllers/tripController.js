const Trip = require('../models/Trip');

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
    }
};

module.exports = tripController;
