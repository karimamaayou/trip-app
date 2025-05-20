const express = require('express');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');
const path = require('path');
const db = require('./config/db'); // Import your database configuration
const pool = require('./config/db'); // Add pool import

// Initialize Express app
const app = express();
const server = http.createServer(app);

// Middleware
app.use(cors());
app.use(express.json({ limit: "50mb" }));

// Serve static files from uploads directory
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

//routes
const authRoutes = require('./routes/auth');
const tripRoutes = require('./routes/trip');
const profileRoutes = require('./routes/profile');
const friendsRoutes = require('./routes/friends');
const dataRoutes = require('./routes/data');
const postRoutes = require('./routes/post');

app.use('/api/auth', authRoutes);
app.use('/api/trips', tripRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/friends', friendsRoutes);
app.use('/api/data', dataRoutes);
app.use('/api', postRoutes);

// Socket.IO setup with CORS
const io = new Server(server, {
  cors: {
    origin: "http://localhost:3001", // Your Flutter app's URL
    methods: ["GET", "POST"]
  }
});

// Socket.IO connection handling
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  // Join trip room
  socket.on('join_trip', (tripId) => {
    socket.join(`trip_${tripId}`);
    console.log(`User ${socket.id} joined trip_${tripId}`);
  });

  // Handle new message
  socket.on('send_message', async (data) => {
    try {
      const { tripId, userId, message } = data;
      
      // Save message to database using pool
      const [result] = await pool.query(
        'INSERT INTO messages_groupe (id_voyage, id_auteur, contenu, date_envoi) VALUES (?, ?, ?, NOW())',
        [tripId, userId, message]
      );

      // Get sender info
      const [users] = await pool.query(
        'SELECT prenom, nom, photo_profil FROM utilisateurs WHERE id_utilisateur = ?',
        [userId]
      );

      const sender = users[0];
      
      // Broadcast to all users in the trip room
      io.to(`trip_${tripId}`).emit('new_message', {
        id: result.insertId,
        tripId,
        userId,
        message,
        sender: {
          prenom: sender.prenom,
          nom: sender.nom,
          photo_profil: sender.photo_profil
        },
        timestamp: new Date()
      });
    } catch (error) {
      console.error('Error sending message:', error);
      socket.emit('error', 'Failed to send message');
    }
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

// Start server
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});