CREATE DATABASE IF NOT EXISTS optimakeDB;
USE optimakeDB;

CREATE TABLE IF NOT EXISTS `University` (
  `university_ID` INT AUTO_INCREMENT,
  `university_name` VARCHAR(255),
  PRIMARY KEY (`university_ID`)
);

CREATE TABLE IF NOT EXISTS `Campus` (
  `campus_ID` INT AUTO_INCREMENT,
  `campus_name` VARCHAR(255),
  `university_ID` INT,
  PRIMARY KEY (`campus_ID`),
  FOREIGN KEY (`university_ID`) REFERENCES `University`(`university_ID`)
);

CREATE TABLE IF NOT EXISTS `College` (
  `college_ID` INT AUTO_INCREMENT,
  `college_name` VARCHAR(255),
  `campus_ID` INT,
  PRIMARY KEY (`college_ID`),
  FOREIGN KEY (`campus_ID`) REFERENCES `Campus`(`campus_ID`)
);

CREATE TABLE IF NOT EXISTS `Course` (
  `course_ID` INT AUTO_INCREMENT,
  `course_code` VARCHAR(255),
  `course_title` VARCHAR(255),
  `units` TINYINT UNSIGNED,
  `section_ID` INT,
  PRIMARY KEY (`course_ID`)
);

CREATE TABLE IF NOT EXISTS `Department` (
  `department_ID` INT AUTO_INCREMENT,
  `department_name` VARCHAR(255),
  `college_ID` INT,
  PRIMARY KEY (`department_ID`),
  FOREIGN KEY (`college_ID`) REFERENCES `College`(`college_ID`)
);

CREATE TABLE IF NOT EXISTS `Faculty` (
  `faculty_ID` INT AUTO_INCREMENT,
  `first_name` VARCHAR(255),
  `last_name` VARCHAR(255),
  `units` TINYINT UNSIGNED,
  `available_time_slots` VARCHAR(255),
  `birthdate` DATE,
  `age` TINYINT UNSIGNED,
  `gender` ENUM('Male', 'Female', 'Other'),
  `contact_number` VARCHAR(255),
  `email` VARCHAR(255) UNIQUE,
  `address` VARCHAR(255),
  PRIMARY KEY (`faculty_ID`)
);

CREATE TABLE IF NOT EXISTS `Room` (
  `room_ID` INT AUTO_INCREMENT,
  `room_name` VARCHAR(255),
  `building_no` INT UNSIGNED,
  `floor_no` TINYINT UNSIGNED,
  `college_ID` INT,
  PRIMARY KEY (`room_ID`),
  FOREIGN KEY (`college_ID`) REFERENCES `College`(`college_ID`)
);

CREATE TABLE IF NOT EXISTS `Section` (
  `section_ID` INT AUTO_INCREMENT,
  `section_name` VARCHAR(255),
  `department_ID` INT,
  PRIMARY KEY (`section_ID`),
  FOREIGN KEY (`department_ID`) REFERENCES `Department`(`department_ID`)
);

CREATE TABLE IF NOT EXISTS `Schedule` (
  `schedule_ID` INT AUTO_INCREMENT,
  `section_ID` INT,
  `course_ID` INT,
  `faculty_ID` INT,
  `room_ID` INT,
  `day` ENUM('M', 'T', 'W', 'Th', 'F', 'S'),
  `start_time` TIME,
  `duration` INT,
  PRIMARY KEY (`schedule_ID`),
  FOREIGN KEY (`room_ID`) REFERENCES `Room`(`room_ID`),
  FOREIGN KEY (`faculty_ID`) REFERENCES `Faculty`(`faculty_ID`),
  FOREIGN KEY (`course_ID`) REFERENCES `Course`(`course_ID`),
  FOREIGN KEY (`section_ID`) REFERENCES `Section`(`section_ID`)
);