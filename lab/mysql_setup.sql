CREATE DATABASE IF NOT EXISTS workshop;

CREATE USER IF NOT EXISTS 'mysql'@'%' IDENTIFIED WITH mysql_native_password BY '';
GRANT ALL PRIVILEGES ON *.* TO 'mysql'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

USE workshop;

CREATE TABLE IF NOT EXISTS flags (
  id INT PRIMARY KEY AUTO_INCREMENT,
  flag VARCHAR(255) NOT NULL
);

INSERT INTO flags(flag)
SELECT 'enum-wkshp{mysql_login_successful}'
WHERE NOT EXISTS (
  SELECT 1 FROM flags WHERE flag='enum-wkshp{mysql_login_successful}'
);