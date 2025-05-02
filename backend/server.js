const express = require('express');
const cors = require('cors');
const http = require('http');
const socketio = require('socket.io');
const db = require('./config/db'); // Import your database configuration

// Initialize Express app
const app = express();
const server = http.createServer(app);

// Socket.io setup
const io = socketio(server, {
  cors: {
    origin: "*",  // Allow all origins (adjust for production)
    methods: ["GET", "POST"]
  }
});

// Middleware
app.use(cors());
app.use(express.json({ limit: "50mb" }));

// Database connection
db.connect((err) => {
  if (err) {
    console.error('Database connection failed:', err);
    process.exit(1);
  }
  console.log('Connected to database');
});

// Basic route
app.get('/', (req, res) => {
  res.send('Server is running with database connection');
});

// Socket.io connection handler
io.on('connection', (socket) => {
  console.log('New client connected');
  
  socket.on('disconnect', () => {
    console.log('Client disconnected');
  });
});

// Start server
const PORT = 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`Access it at http://localhost:${PORT}`);
});