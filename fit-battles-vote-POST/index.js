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
  const batchInsert = event.votes.map(vote => new Array(1).fill(vote))
  conn.query('INSERT INTO votes (postId) VALUES ?', [batchInsert], function(err, result) {
    if (err) {
      callback(err)
    } else {
      if (result.affectedRows) {
        callback(null, { message: 'success' })
      } else {
        callback(null, { message: 'fail' })
      }
    }
  })
};
