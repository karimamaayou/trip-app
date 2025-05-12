const mysql = require('mysql2/promise');

const pool = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'tripapp',
    waitForConnections: true,
    connectionLimit: 10,   // Tu peux ajuster selon besoin
    queueLimit: 0
});

pool.getConnection()
    .then(() => console.log('✅ Connected to Database (Promise pool)!'))
    .catch(err => console.error('❌ Database connection error:', err));

module.exports = pool;
