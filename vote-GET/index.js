const mysql = require('mysql')

const db_config = {
  host     : process.env.RDS_HOST,
  user     : process.env.RDS_USER,
  password : process.env.RDS_PASSWORD,
  database : process.env.RDS_DATABASE,
  timezone: 'UTC'
}

if (typeof client === 'undefined') {
  var conn = mysql.createConnection(db_config)
  conn.connect()
}

exports.handler = function(event, context, callback) {
  context.callbackWaitsForEmptyEventLoop = false;
  conn.query('SELECT * FROM posts', [], function(err, result) {
    if (err) {
      callback(err)
    } else {
      callback(null, result)
    }
  })
};
