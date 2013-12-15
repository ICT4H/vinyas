CREATE DATABASE IF NOT EXISTS openmrs DEFAULT CHARACTER SET utf8;

use openmrs;

CREATE TABLE IF NOT EXISTS `liquibasechangelog` (
			  `ID` varchar(63) NOT NULL,
			  `AUTHOR` varchar(63) NOT NULL,
			  `FILENAME` varchar(200) NOT NULL,
			  `DATEEXECUTED` datetime NOT NULL,
			  `MD5SUM` varchar(32) DEFAULT NULL,
			  `DESCRIPTION` varchar(255) DEFAULT NULL,
			  `COMMENTS` varchar(255) DEFAULT NULL,
			  `TAG` varchar(255) DEFAULT NULL,
			  `LIQUIBASE` varchar(10) DEFAULT NULL,
			  `EXECTYPE` varchar(20) DEFAULT NULL,
			  `ORDEREXECUTED` varchar(20) DEFAULT NULL,
			  PRIMARY KEY (`ID`,`AUTHOR`,`FILENAME`)
			) ENGINE=InnoDB DEFAULT CHARSET=utf8;


GRANT USAGE ON openmrs.* TO 'openmrs-user'@'localhost';
GRANT USAGE ON openmrs.* TO 'openmrs-user'@'%';
DROP USER 'openmrs-user'@'localhost';
DROP USER 'openmrs-user'@'%';

CREATE USER 'openmrs-user'@'localhost' identified by 'password';
CREATE USER 'openmrs-user'@'%' identified by 'password';
GRANT ALL PRIVILEGES ON openmrs.* TO 'openmrs-user'@'%' identified by 'password';
GRANT ALL PRIVILEGES ON openmrs.* TO 'openmrs-user'@'localhost' identified by 'password';
FLUSH PRIVILEGES;