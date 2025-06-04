const express = require("express");
const cors = require("cors");
const http = require("http");
const { Server } = require("socket.io");
const path = require("path");
const pool = require("./config/db");

// Initialize Express app
const app = express();
const server = http.createServer(app);

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files
app.use("/uploads", express.static(path.join(__dirname, "uploads")));
app.use("/trip_images", express.static(path.join(__dirname, "trip_images")));

// Routes
const authRoutes = require("./routes/auth");
const tripRoutes = require("./routes/trip");
const profileRoutes = require("./routes/profile");
const friendsRoutes = require("./routes/friends");
const dataRoutes = require("./routes/data");
const postRoutes = require("./routes/post");
const mapRoutes = require("./routes/map");
const locationRoutes = require("./routes/location");
const userRoutes = require("./routes/users");


const dashbordRoutes = require("./routes/dashbordRoutes");



const dashbordServer = require("./routes/dashbordServer");
app.use("/api/dashbord", dashbordServer); 
// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/trips', tripRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/friends', friendsRoutes);
app.use('/api/users', userRoutes);
app.use('/api/data', dataRoutes);
app.use('/api/posts', postRoutes);
app.use('/api/voyages', mapRoutes);
app.use('/api/map', locationRoutes);
app.use("/api/dashboard", dashbordRoutes);
const io = new Server(server, {
  cors: {
    origin: "*", // Allow all origins for development
    methods: ["GET", "POST"],
  },
});

// Socket.IO connection handling
io.on("connection", (socket) => {
  console.log("User connected:", socket.id);

  socket.on("join_trip", (tripId) => {
    socket.join(`trip_${tripId}`);
    console.log(`User ${socket.id} joined trip_${tripId}`);
  });

  socket.on("send_message", async (data) => {
    try {
      const { tripId, userId, message } = data;

      // Insert message into database
      const [result] = await pool.query(
        "INSERT INTO messages_groupe (id_voyage, id_auteur, contenu, date_envoi) VALUES (?, ?, ?, NOW())",
        [tripId, userId, message]
      );

      // Get sender info
      const [users] = await pool.query(
        "SELECT prenom, nom, photo_profil FROM utilisateurs WHERE id_utilisateur = ?",
        [userId]
      );

      if (users.length === 0) {
        throw new Error("User not found");
      }

      const sender = users[0];

      // Format the message data exactly like the working version
      const messageData = {
        id: result.insertId,
        tripId,
        userId,
        message,
        timestamp: new Date(),
        sender: {
          prenom: sender.prenom,
          nom: sender.nom,
          photo_profil: sender.photo_profil, // Send the raw photo path, let the client handle the URL
        },
      };

      // Broadcast to all users in the trip room
      io.to(`trip_${tripId}`).emit("new_message", messageData);
    } catch (error) {
      console.error("Error sending message:", error);
      socket.emit("error", {
        message: "Failed to send message",
        error: error.message,
      });
    }
  });

  socket.on("disconnect", () => {
    console.log("User disconnected:", socket.id);
  });
});

// 404 handler
app.use((req, res, next) => {
  console.log("404 Not Found:", req.method, req.path);
  res.status(404).json({
    error: "Route non trouvée",
    path: req.path,
    method: req.method,
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error("Error details:", {
    message: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
  });

  res.status(500).json({
    error: "Une erreur est survenue",
    message: err.message,
    path: req.path,
  });
});

// Start server
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
