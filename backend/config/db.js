const mysql = require('mysql2');
const connection =mysql.createConnection({
  host: 'localhost',    
  user: 'root',          
  password: '',         
  database: 'tripapp',
});

connection.connect(
    (err) => {
      if(err){
        console.error('Error connecting to database: ',err);
        return;
      }
      console.log('Connected to Database!');
        

    }
);

module.exports = connection;