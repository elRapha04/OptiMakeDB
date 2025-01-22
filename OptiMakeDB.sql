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

-- ================================================
-- STORED FUNCTIONS
-- ================================================
DELIMITER $$

-- Function: Retrieve available time slots for a specific faculty member
CREATE FUNCTION GetAvailableTimeSlots(faculty_ID INT)
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE slots VARCHAR(255);
    SELECT available_time_slots INTO slots
    FROM Faculty
    WHERE faculty_ID = faculty_ID;
    RETURN slots;
END $$

-- Function: Check for schedule conflict in a specific section
CREATE FUNCTION CheckSectionConflict(section_ID INT, day ENUM('M', 'T', 'W', 'Th', 'F', 'S'), start_time TIME, duration INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE conflict BOOLEAN;
    SET conflict = EXISTS (
        SELECT 1
        FROM Schedule
        WHERE section_ID = section_ID
          AND day = day
          AND (
              (start_time >= start_time AND start_time < ADDTIME(start_time, SEC_TO_TIME(duration * 60))) OR
              (ADDTIME(start_time, SEC_TO_TIME(duration * 60)) > start_time AND ADDTIME(start_time, SEC_TO_TIME(duration * 60)) <= ADDTIME(start_time, SEC_TO_TIME(duration * 60)))
          )
    );
    RETURN conflict;
END $$

-- Function: Check for schedule conflict with a faculty member's schedule
CREATE FUNCTION CheckFacultyConflict(faculty_ID INT, day ENUM('M', 'T', 'W', 'Th', 'F', 'S'), start_time TIME, duration INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE conflict BOOLEAN;
    SET conflict = EXISTS (
        SELECT 1
        FROM Schedule
        WHERE faculty_ID = faculty_ID
          AND day = day
          AND (
              (start_time >= start_time AND start_time < ADDTIME(start_time, SEC_TO_TIME(duration * 60))) OR
              (ADDTIME(start_time, SEC_TO_TIME(duration * 60)) > start_time AND ADDTIME(start_time, SEC_TO_TIME(duration * 60)) <= ADDTIME(start_time, SEC_TO_TIME(duration * 60)))
          )
    );
    RETURN conflict;
END $$

-- Function: Check for schedule conflict with a room's schedule
CREATE FUNCTION CheckRoomConflict(room_ID INT, day ENUM('M', 'T', 'W', 'Th', 'F', 'S'), start_time TIME, duration INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE conflict BOOLEAN;
    SET conflict = EXISTS (
        SELECT 1
        FROM Schedule
        WHERE room_ID = room_ID
          AND day = day
          AND (
              (start_time >= start_time AND start_time < ADDTIME(start_time, SEC_TO_TIME(duration * 60))) OR
              (ADDTIME(start_time, SEC_TO_TIME(duration * 60)) > start_time AND ADDTIME(start_time, SEC_TO_TIME(duration * 60)) <= ADDTIME(start_time, SEC_TO_TIME(duration * 60)))
          )
    );
    RETURN conflict;
END $$

DELIMITER ;

-- ================================================
-- STORED PROCEDURES
-- ================================================
DELIMITER $$

-- Procedure: Assign a course to a specific faculty member
CREATE PROCEDURE AssignCourse(IN faculty_ID INT, IN course_ID INT)
BEGIN
    INSERT INTO AssignedCourses (faculty_ID, course_ID)
    VALUES (faculty_ID, course_ID);
END $$

-- Procedure: Add a new schedule entry for a specific course and section
CREATE PROCEDURE AddSchedule(IN section_ID INT, IN course_ID INT, IN faculty_ID INT, IN room_ID INT, IN day ENUM('M', 'T', 'W', 'Th', 'F', 'S'), IN start_time TIME, IN duration INT)
BEGIN
    INSERT INTO Schedule (section_ID, course_ID, faculty_ID, room_ID, day, start_time, duration)
    VALUES (section_ID, course_ID, faculty_ID, room_ID, day, start_time, duration);
END $$

-- Procedure: Update a faculty member's available time slots
CREATE PROCEDURE UpdateFacultyTimeSlots(IN faculty_ID INT, IN new_time_slots VARCHAR(255))
BEGIN
    UPDATE Faculty
    SET available_time_slots = new_time_slots
    WHERE faculty_ID = faculty_ID;
END $$

-- Procedure: Assign a faculty member to a specific course and section
CREATE PROCEDURE AssignFacultyToCourse(IN faculty_ID INT, IN section_ID INT, IN course_ID INT)
BEGIN
    UPDATE Schedule
    SET faculty_ID = faculty_ID
    WHERE section_ID = section_ID AND course_ID = course_ID;
END $$

-- Procedure: Remove or cancel an existing schedule entry
CREATE PROCEDURE RemoveSchedule(IN schedule_ID INT)
BEGIN
    DELETE FROM Schedule
    WHERE schedule_ID = schedule_ID;
END $$

-- Procedure: Generate a complete schedule report for a specific section in JSON format
CREATE PROCEDURE GenerateSectionScheduleReport(IN section_ID INT, OUT scheduleReport JSON)
BEGIN
    SET scheduleReport = (
        SELECT JSON_ARRAYAGG(JSON_OBJECT(
            'schedule_ID', schedule_ID,
            'course_ID', course_ID,
            'faculty_ID', faculty_ID,
            'room_ID', room_ID,
            'day', day,
            'start_time', start_time,
            'duration', duration
        ))
        FROM Schedule
        WHERE section_ID = section_ID
    );
END $$

-- Procedure: Add a new department, section, or room to the system
CREATE PROCEDURE AddNewEntity(IN entityType ENUM('Department', 'Section', 'Room'), IN entityName VARCHAR(255), IN parentID INT)
BEGIN
    IF entityType = 'Department' THEN
        INSERT INTO Department (department_name, college_ID) VALUES (entityName, parentID);
    ELSEIF entityType = 'Section' THEN
        INSERT INTO Section (section_name, department_ID) VALUES (entityName, parentID);
    ELSEIF entityType = 'Room' THEN
        INSERT INTO Room (room_name, college_ID) VALUES (entityName, parentID);
    END IF;
END $$

-- Procedure: Validate faculty workload to ensure it does not exceed allowed teaching units
CREATE PROCEDURE ValidateFacultyWorkload(IN faculty_ID INT, OUT isValid BOOLEAN)
BEGIN
    DECLARE totalUnits INT;
    SELECT SUM(duration) / 60 INTO totalUnits
    FROM Schedule
    WHERE faculty_ID = faculty_ID;

    SET isValid = totalUnits <= (SELECT units FROM Faculty WHERE faculty_ID = faculty_ID);
END $$

DELIMITER ;

-- DUMMY DATA FOR TESTING