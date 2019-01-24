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
  conn.query('SELECT COUNT(*) AS votes, b.* FROM votes AS a JOIN posts AS b ON b.postId = a.postId GROUP BY a.postId ORDER BY a.postId;', [], function(err, result) {
    if (err) {
      callback(err)
    } else {
      var battles = []
      for (var i = 1; i < result.length; i+= 2) {
        battles.push([result[i - 1], result[i]])
      }
      callback(null, battles)
    }
  })
};
