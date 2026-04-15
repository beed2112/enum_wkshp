CREATE USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';
FLUSH PRIVILEGES;
USE workshop;
CREATE TABLE IF NOT EXISTS flags (
  id INT PRIMARY KEY AUTO_INCREMENT,
  flag VARCHAR(255) NOT NULL
);
INSERT INTO flags(flag)
SELECT 'enum-wkshp{mysql_login_successful}'
WHERE NOT EXISTS (SELECT 1 FROM flags WHERE flag='enum-wkshp{mysql_login_successful}');
