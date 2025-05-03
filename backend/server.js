const express = require('express');
const cors = require('cors');
const http = require('http');
const socketio = require('socket.io');
const path = require('path');
const db = require('./config/db'); // Import your database configuration

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

app.use('/api/auth', authRoutes);
app.use('/api/trips', tripRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/friends', friendsRoutes);
app.use('/api/data', dataRoutes);

// Socket.io connection handler

// Start server
const PORT = 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`Access it at http://localhost:${PORT}`);
});