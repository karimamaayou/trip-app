const db = require('../config/db');

const Trip = {
    getAllTrips: async () => {
        try {
            const [trips] = await db.query(`
                SELECT v.*, 
                       vd.nom_ville as ville_depart,
                       va.nom_ville as ville_arrivee
                FROM voyages v
                LEFT JOIN ville vd ON v.id_ville_depart = vd.id_ville
                LEFT JOIN ville va ON v.id_ville_destination = va.id_ville
            `);

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

            return trips;
        } catch (error) {
            console.error('Error in getAllTrips:', error);
            throw error;
        }
    },

    getTripDetails: async (tripId) => {
        try {
            const [trip] = await db.query(`
                SELECT v.*, 
                       vd.nom_ville as ville_depart,
                       va.nom_ville as ville_arrivee
                FROM voyages v
                LEFT JOIN ville vd ON v.id_ville_depart = vd.id_ville
                LEFT JOIN ville va ON v.id_ville_destination = va.id_ville
                WHERE v.id_voyage = ?
            `, [tripId]);

            if (!trip) {
                return null;
            }

            const [participants] = await db.query(`
                SELECT p.*, u.nom, u.prenom, u.email, u.photo_profil
                FROM participations p
                JOIN utilisateurs u ON p.id_voyageur = u.id_utilisateur
                WHERE p.id_voyage = ?
            `, [tripId]);

            const [activities] = await db.query(`
                SELECT a.*
                FROM activities a
                JOIN voyage_activities va ON a.id_activity = va.id_activity
                WHERE va.id_voyage = ?
            `, [tripId]);

            const [images] = await db.query(`
                SELECT chemin
                FROM images
                WHERE id_voyage = ?
            `, [tripId]);

            // Add the correct path prefix to images
            const formattedImages = images.map(img => ({
                ...img,
                chemin: `/uploads/trip_images/${img.chemin}`
            }));

            return {
                ...trip,
                participants,
                activities,
                images: formattedImages
            };
        } catch (error) {
            console.error('Error in getTripDetails:', error);
            throw error;
        }
    },

    createTrip: async (tripData) => {
        try {
            const { titre, description, date_depart, date_retour, capacite_max, id_ville_depart, id_ville_destination } = tripData;
            
            const [result] = await db.query(`
                INSERT INTO voyages (titre, description, date_depart, date_retour, capacite_max, id_ville_depart, id_ville_destination)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            `, [titre, description, date_depart, date_retour, capacite_max, id_ville_depart, id_ville_destination]);

            return result.insertId;
        } catch (error) {
            console.error('Error in createTrip:', error);
            throw error;
        }
    },

    addActivityToTrip: async (tripId, activityId) => {
        try {
            await db.query(`
                INSERT INTO voyage_activities (id_voyage, id_activity)
                VALUES (?, ?)
            `, [tripId, activityId]);
        } catch (error) {
            console.error('Error in addActivityToTrip:', error);
            throw error;
        }
    },

    joinTrip: async (tripId, userId, role = 'voyageur') => {
        try {
            await db.query(`
                INSERT INTO participations (id_voyage, id_voyageur, role)
                VALUES (?, ?, ?)
            `, [tripId, userId, role]);
        } catch (error) {
            console.error('Error in joinTrip:', error);
            throw error;
        }
    },

    getUserTrips: async (userId) => {
        try {
            const [trips] = await db.query(`
                SELECT v.*, 
                       vd.nom_ville as ville_depart,
                       va.nom_ville as ville_arrivee,
                       p.statut
                FROM voyages v
                LEFT JOIN ville vd ON v.id_ville_depart = vd.id_ville
                LEFT JOIN ville va ON v.id_ville_destination = va.id_ville
                JOIN participations p ON v.id_voyage = p.id_voyage
                WHERE p.id_voyageur = ?
                ORDER BY v.date_depart DESC
            `, [userId]);

            return trips;
        } catch (error) {
            console.error('Error in getUserTrips:', error);
            throw error;
        }
    },

    getTripDetailsById: async (tripId) => {
        try {
            console.log('🔍 Fetching trip details for ID:', tripId);
            
            const [trip] = await db.query(`
                SELECT v.*, 
                       vd.nom_ville as ville_depart,
                       va.nom_ville as ville_arrivee
                FROM voyages v
                LEFT JOIN ville vd ON v.id_ville_depart = vd.id_ville
                LEFT JOIN ville va ON v.id_ville_destination = va.id_ville
                WHERE v.id_voyage = ?
            `, [tripId]);

            if (!trip) {
                console.log('❌ No trip found with ID:', tripId);
                return null;
            }

            console.log('✅ Trip found:', trip);

            const [participants] = await db.query(`
                SELECT p.*, u.nom, u.prenom, u.email, u.photo_profil
                FROM participations p
                JOIN utilisateurs u ON p.id_voyageur = u.id_utilisateur
                WHERE p.id_voyage = ? AND p.statut = 'accepte'
            `, [tripId]);

            const [activities] = await db.query(`
                SELECT a.*
                FROM activities a
                JOIN voyage_activities va ON a.id_activity = va.id_activity
                WHERE va.id_voyage = ?
            `, [tripId]);

            console.log('📸 Fetching images for trip ID:', tripId);
            const [images] = await db.query(`
                SELECT chemin
                FROM images
                WHERE id_voyage = ?
            `, [tripId]);
            
            console.log('📸 Raw images from database:', images);

            // Add the correct path prefix to images
            const formattedImages = images.map(img => ({
                ...img,
                chemin: `/uploads/trip_images/${img.chemin}`
            }));

            console.log('📸 Formatted images:', formattedImages);

            const result = {
                ...trip,
                participants,
                activities,
                images: formattedImages
            };

            console.log('✅ Final response:', result);
            return result;
        } catch (error) {
            console.error('❌ Error in getTripDetailsById:', error);
            throw error;
        }
    },

    getAllTripParticipants: async (tripId) => {
        try {
            const [participants] = await db.query(`
                SELECT p.*, u.nom, u.prenom, u.email, u.photo_profil
                FROM participations p
                JOIN utilisateurs u ON p.id_voyageur = u.id_utilisateur
                WHERE p.id_voyage = ?
            `, [tripId]);
            return participants;
        } catch (error) {
            console.error('Error in getAllTripParticipants:', error);
            throw error;
        }
    },

    getVoyageParticipants: async (voyageId) => {
        try {
            const [participants] = await db.query(`
                SELECT p.*, 
                       u.nom, 
                       u.prenom, 
                       u.email, 
                       u.photo_profil,
                       u.role as user_role
                FROM participations p
                JOIN utilisateurs u ON p.id_voyageur = u.id_utilisateur
                WHERE p.id_voyage = ?
                ORDER BY p.date_inscription DESC
            `, [voyageId]);

            return participants;
        } catch (error) {
            console.error('Error in getVoyageParticipants:', error);
            throw error;
        }
    }
};

module.exports = Trip;
