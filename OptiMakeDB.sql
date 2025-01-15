CREATE DATABASE IF NOT EXISTS optimakeDB;
USE optimakeDB;

CREATE TABLE IF NOT EXISTS `University` (
  `university_ID` INT AUTO_INCREMENT,
  `university_name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`university_ID`)
);

CREATE TABLE IF NOT EXISTS `Campus` (
  `campus_ID` INT AUTO_INCREMENT,
  `campus_name` VARCHAR(255) NOT NULL,
  `university_ID` INT NOT NULL,
  PRIMARY KEY (`campus_ID`),
  FOREIGN KEY (`university_ID`) REFERENCES `University`(`university_ID`)
);

CREATE TABLE IF NOT EXISTS `College` (
  `college_ID` INT AUTO_INCREMENT,
  `college_name` VARCHAR(255) NOT NULL,
  `campus_ID` INT NOT NULL,
  PRIMARY KEY (`college_ID`),
  FOREIGN KEY (`campus_ID`) REFERENCES `Campus`(`campus_ID`)
);

CREATE TABLE IF NOT EXISTS `Department` (
  `department_ID` INT AUTO_INCREMENT,
  `department_name` VARCHAR(255) NOT NULL,
  `college_ID` INT NOT NULL,
  PRIMARY KEY (`department_ID`),
  FOREIGN KEY (`college_ID`) REFERENCES `College`(`college_ID`)
);

CREATE TABLE IF NOT EXISTS `Faculty` (
  `faculty_ID` INT AUTO_INCREMENT NOT NULL,
  `first_name` VARCHAR(255) NOT NULL,
  `last_name` VARCHAR(255) NOT NULL,
  `units` TINYINT UNSIGNED NOT NULL,
  `available_time_slots` VARCHAR(255) NOT NULL,
  `birthdate` DATE NOT NULL,
  `age` TINYINT UNSIGNED NOT NULL,
  `gender` ENUM('Male', 'Female', 'Other') NOT NULL,
  `contact_number` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) UNIQUE NOT NULL,
  `address` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`faculty_ID`)
);

CREATE TABLE IF NOT EXISTS `Room` (
  `room_ID` INT AUTO_INCREMENT,
  `room_no` INT UNSIGNED NOT NULL,
  `room_name` VARCHAR(255),
  `building_no` INT UNSIGNED NOT NULL,
  `building_name` VARCHAR(255),
  `floor_no` TINYINT UNSIGNED NOT NULL,
  `college_ID` INT,
  PRIMARY KEY (`room_ID`),
  FOREIGN KEY (`college_ID`) REFERENCES `College`(`college_ID`)
);

CREATE TABLE IF NOT EXISTS `Section` (
  `section_ID` INT AUTO_INCREMENT,
  `section_name` VARCHAR(255) NOT NULL,
  `department_ID` INT NOT NULL,
  PRIMARY KEY (`section_ID`),
  FOREIGN KEY (`department_ID`) REFERENCES `Department`(`department_ID`)
);

-- QUESTION: separate units to lab and lecture?
CREATE TABLE IF NOT EXISTS `Course` (
  `course_ID` INT AUTO_INCREMENT,
  `course_code` VARCHAR(255) NOT NULL,
  `course_title` VARCHAR(255) NOT NULL,
  `units` TINYINT UNSIGNED NOT NULL,
  `section_ID` INT,
  PRIMARY KEY (`course_ID`),
  FOREIGN KEY (`section_ID`) REFERENCES `Section`(`section_ID`)
);

-- QUESTION: add `type` enum(lab, lecture)?
CREATE TABLE IF NOT EXISTS `Schedule` (
  `schedule_ID` INT AUTO_INCREMENT,
  `section_ID` INT NOT NULL,
  `course_ID` INT NOT NULL,
  `faculty_ID` INT,
  `room_ID` INT,
  `day` ENUM('M', 'T', 'W', 'Th', 'F', 'S') NOT NULL,
  `start_time` TIME NOT NULL,
  `duration` INT NOT NULL,
  PRIMARY KEY (`schedule_ID`),
  FOREIGN KEY (`room_ID`) REFERENCES `Room`(`room_ID`),
  FOREIGN KEY (`faculty_ID`) REFERENCES `Faculty`(`faculty_ID`),
  FOREIGN KEY (`course_ID`) REFERENCES `Course`(`course_ID`),
  FOREIGN KEY (`section_ID`) REFERENCES `Section`(`section_ID`)
);