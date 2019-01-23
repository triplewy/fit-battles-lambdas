CREATE TABLE IF NOT EXISTS posts (
  postId INTEGER AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(255) NOT NULL,
  imageUrl VARCHAR(255) NOT NULL UNIQUE,
  createdDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS shifts (
  shiftId INTEGER AUTO_INCREMENT PRIMARY KEY,
  companyId INTEGER NOT NULL,
  minutes INTEGER NOT NULL,
  FOREIGN KEY(companyId) REFERENCES companies(companyId),
  UNIQUE(companyId, minutes)
);

CREATE TABLE IF NOT EXISTS users (
  userId INTEGER AUTO_INCREMENT PRIMARY KEY,
  companyId INTEGER,
  createdDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  isAdmin BOOLEAN DEFAULT FALSE NOT NULL,
  FOREIGN KEY(companyId) REFERENCES companies(companyId)
);

CREATE TABLE IF NOT EXISTS logins (
  loginId INTEGER AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(255) NOT NULL UNIQUE,
  userId INTEGER NOT NULL,
  passwordHash CHAR(60),
  FOREIGN KEY (userId) REFERENCES users(userId) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS names (
  nameId INTEGER AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  companyId INTEGER NOT NULL,
  FOREIGN KEY (companyId) REFERENCES companies(companyId),
  UNIQUE(name, companyId)
);

CREATE TABLE IF NOT EXISTS mechanics (
  mechanicId INTEGER AUTO_INCREMENT PRIMARY KEY,
  companyId INTEGER NOT NULL,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  startHour INTEGER NOT NULL,
  endHour INTEGER NOT NULL,
  FOREIGN KEY (companyId) REFERENCES companies(companyId)
);

CREATE TABLE IF NOT EXISTS assemblyLines (
  lineId INTEGER AUTO_INCREMENT PRIMARY KEY,
  companyId INTEGER NOT NULL,
  name VARCHAR(255) NOT NULL,
  morningShift INTEGER NOT NULL,
  eveningShift INTEGER NOT NULL,
  createdDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  FOREIGN KEY (companyId) REFERENCES companies(companyId)
);

CREATE TABLE IF NOT EXISTS assemblyLineUsers (
  lineId INTEGER NOT NULL,
  userId INTEGER NOT NULL,
  FOREIGN KEY(lineId) REFERENCES assemblyLines(lineId),
  FOREIGN KEY(userId) REFERENCES users(userId) ON DELETE CASCADE,
  UNIQUE(lineId, userId)
);

CREATE TABLE IF NOT EXISTS assemblyLineMechanics (
  lineId INTEGER NOT NULL,
  mechanicId INTEGER NOT NULL,
  FOREIGN KEY(lineId) REFERENCES assemblyLines(lineId),
  FOREIGN KEY(mechanicId) REFERENCES mechanics(mechanicId) ON DELETE CASCADE,
  UNIQUE(lineId, mechanicId)
);

CREATE TABLE IF NOT EXISTS machines (
  machineId INTEGER AUTO_INCREMENT PRIMARY KEY,
  lineId INTEGER NOT NULL,
  name VARCHAR(255) NOT NULL,
  icon_url VARCHAR(255) DEFAULT 'https://s3.us-east-2.amazonaws.com/manufacturing-app-icons/example-icon.png' NOT NULL,
  createdDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  FOREIGN KEY(lineId) REFERENCES assemblyLines(lineId),
  UNIQUE(lineId, name)
);

CREATE TABLE IF NOT EXISTS downtime (
  downtimeId INTEGER AUTO_INCREMENT PRIMARY KEY,
  machineId INTEGER NOT NULL,
  lineId INTEGER NOT NULL,
  lineLeaderName VARCHAR(255) NOT NULL,
  downtime INTEGER NOT NULL,
  availableMin INTEGER NOT NULL DEFAULT 600,
  description TEXT,
  createdDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  FOREIGN KEY(machineId) REFERENCES machines(machineId),
  FOREIGN KEY(lineId) REFERENCES assemblyLines(lineId)
);

CREATE TABLE IF NOT EXISTS downtimeImages (
  downtimeImageId INTEGER AUTO_INCREMENT PRIMARY KEY,
  downtimeId INTEGER NOT NULL,
  imageUrl VARCHAR(255) NOT NULL,
  createdDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  FOREIGN KEY(downtimeId) REFERENCES downtime(downtimeId) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS notifications (
  notificationId INTEGER AUTO_INCREMENT PRIMARY KEY,
  companyId INTEGER NOT NULL,
  userId INTEGER,
  isGlobal BOOLEAN NOT NULL DEFAULT FALSE,
  message VARCHAR(255) NOT NULL,
  createdDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  FOREIGN KEY(companyId) REFERENCES companies(companyId),
  FOREIGN KEY(userId) REFERENCES users(userId) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS workOrders (
  workOrderId INTEGER AUTO_INCREMENT PRIMARY KEY,
  lineId INTEGER NOT NULL,
  machineId INTEGER NOT NULL,
  stars INTEGER NOT NULL,
  description VARCHAR(255),
  createdDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  approvalHash VARCHAR(255) NOT NULL,
  approved BOOLEAN NOT NULL DEFAULT FALSE,
  finishedDate DATETIME,
  FOREIGN KEY (lineId) REFERENCES assemblyLines(lineId),
  FOREIGN KEY (machineId) REFERENCES machines(machineId)
);

CREATE TABLE IF NOT EXISTS workOrderImages (
  workOrderImageId INTEGER AUTO_INCREMENT PRIMARY KEY,
  workOrderId INTEGER NOT NULL,
  imageUrl VARCHAR(255) NOT NULL,
  createdDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  FOREIGN KEY(workOrderId) REFERENCES workOrders(workOrderId) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS changeovers (
  changeoverId INTEGER AUTO_INCREMENT PRIMARY KEY,
  lineId INTEGER NOT NULL,
  title VARCHAR(255) NOT NULL,
  createdDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  FOREIGN KEY(lineId) REFERENCES assemblyLines(lineId)
);

CREATE TABLE IF NOT EXISTS changeoverSteps(
  changeoverStepId INTEGER AUTO_INCREMENT PRIMARY KEY,
  changeoverId INTEGER NOT NULL,
  instructions VARCHAR(1023) NOT NULL,
  imageUrl VARCHAR(255),
  step INTEGER NOT NULL,
  createdDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  FOREIGN KEY(changeoverId) REFERENCES changeovers(changeoverId)
);

DELIMITER //
CREATE TRIGGER before_downtime_insert BEFORE INSERT ON downtime FOR EACH ROW
  BEGIN
  SET NEW.lineId = (SELECT lineId FROM machines WHERE machineId = NEW.machineId);
  END //
DELIMITER ;