CREATE DATABASE IF NOT EXISTS workshop;
CREATE DATABASE IF NOT EXISTS wordpress;

CREATE USER IF NOT EXISTS 'mysql'@'%' IDENTIFIED BY '';
GRANT ALL PRIVILEGES ON *.* TO 'mysql'@'%' WITH GRANT OPTION;
CREATE USER IF NOT EXISTS 'wordpress'@'localhost' IDENTIFIED BY 'wordpress';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost';
CREATE USER IF NOT EXISTS 'wordpress'@'%' IDENTIFIED BY 'wordpress';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'%';
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