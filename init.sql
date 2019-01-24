CREATE TABLE IF NOT EXISTS posts (
  postId INTEGER AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(255) NOT NULL,
  imageUrl VARCHAR(255) NOT NULL UNIQUE,
  createdDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS votes (
  voteId INTEGER AUTO_INCREMENT PRIMARY KEY,
  postId INTEGER NOT NULL,
  createdDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  FOREIGN KEY(postId) REFERENCES posts(postId),
  UNIQUE(voteId, postId)
);
