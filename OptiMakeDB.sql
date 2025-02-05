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
  `latitude` DECIMAL(9,6),
  `longitude` DECIMAL(9,6),
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
  PRIMARY KEY (`faculty_ID`)
);

CREATE TABLE IF NOT EXISTS `Faculty_AvailableTimeSlots`(
  `faculty_ID` INT,
  `day` ENUM('M', 'T', 'W', 'Th', 'F', 'S') NOT NULL,
  `start_time` TIME NOT NULL,
  `end_time` TIME NOT NULL
  FOREIGN KEY (`faculty_ID`) REFERENCES `Faculty`(`faculty_ID`),
);

CREATE TABLE IF NOT EXISTS `Administrator` (
  `admin_ID` INT AUTO_INCREMENT NOT NULL,
  `university_ID` INT NOT NULL,
  `campus_ID` INT NOT NULL,
  PRIMARY KEY (`admin_ID`),
  FOREIGN KEY (`university_ID`) REFERENCES `University`(`university_ID`),
  FOREIGN KEY (`campus_ID`) REFERENCES `Campus`(`campus_ID`)
);

CREATE TABLE IF NOT EXISTS `Dean` (
  `dean_ID` INT AUTO_INCREMENT NOT NULL,
  `university_ID` INT NOT NULL,
  `campus_ID` INT NOT NULL,
  `college_ID` INT NOT NULL,
  PRIMARY KEY (`dean_ID`),
  FOREIGN KEY (`university_ID`) REFERENCES `University`(`university_ID`),
  FOREIGN KEY (`campus_ID`) REFERENCES `Campus`(`campus_ID`),
  FOREIGN KEY (`college_ID`) REFERENCES `College`(`college_ID`)
);

CREATE TABLE IF NOT EXISTS `Chairperson` (
  `chairperson_ID` INT AUTO_INCREMENT NOT NULL,
  `university_ID` INT NOT NULL,
  `campus_ID` INT NOT NULL,
  `college_ID` INT NOT NULL,
  `department_ID` INT NOT NULL,
  PRIMARY KEY (`chairperson_ID`),
  FOREIGN KEY (`university_ID`) REFERENCES `University`(`university_ID`),
  FOREIGN KEY (`campus_ID`) REFERENCES `Campus`(`campus_ID`),
  FOREIGN KEY (`college_ID`) REFERENCES `College`(`college_ID`),
  FOREIGN KEY (`department_ID`) REFERENCES `Department`(`department_ID`)
);

-- EDIT ROLE ATTRIB NAME
CREATE TABLE IF NOT EXISTS `Account` (
  `username` VARCHAR(255) UNIQUE NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `role` ENUM('Admin', 'Dean', 'Chairperson') NOT NULL,
  `first_name` VARCHAR(255) NOT NULL,
  `last_name` VARCHAR(255) NOT NULL,
  `birthdate` DATE NOT NULL,
  `age` TINYINT UNSIGNED NOT NULL,
  `gender` ENUM('Male', 'Female', 'Other') NOT NULL,
  `contact_number` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) UNIQUE NOT NULL,
);


CREATE TABLE IF NOT EXISTS `Building` (
  `building_ID` INT AUTO_INCREMENT,
  `building_no` INT,
  `building_name` VARCHAR,
  `latitude` DECIMAL(9,6),
  `longitude` DECIMAL(9,6),
  PRIMARY KEY (`building_ID`)
);

CREATE TABLE IF NOT EXISTS `Apparatus` (
  `apparatus_ID` INT AUTO_INCREMENT,
  `apparatus_name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`apparatus_ID`)
);

-- college_ID?
CREATE TABLE IF NOT EXISTS `Room` (
  `room_ID` INT AUTO_INCREMENT,
  `room_no` INT UNSIGNED NOT NULL,
  `room_name` VARCHAR(255),
  `building_ID` INT NOT NULL,
  `floor_no` TINYINT UNSIGNED NOT NULL,
  `apparatus_ID` INT,
  `college_ID` INT,
  PRIMARY KEY (`room_ID`),
  FOREIGN KEY (`apparatus_ID`) REFERENCES `Apparatus`(`apparatus_ID`),
  FOREIGN KEY (`building_ID`) REFERENCES `Building`(`building_ID`),
  FOREIGN KEY (`college_ID`) REFERENCES `College`(`college_ID`)
);

-- why include UCCD?
CREATE TABLE IF NOT EXISTS `Section` (
  `section_ID` INT AUTO_INCREMENT,
  `section_name` VARCHAR(255) NOT NULL,
  `university_ID` INT NOT NULL,
  `campus_ID` INT NOT NULL,
  `college_ID` INT NOT NULL,
  `department_ID` INT NOT NULL,
  PRIMARY KEY (`section_ID`),
  FOREIGN KEY (`university_ID`) REFERENCES `University`(`university_ID`),
  FOREIGN KEY (`campus_ID`) REFERENCES `Campus`(`campus_ID`),
  FOREIGN KEY (`college_ID`) REFERENCES `College`(`college_ID`),
  FOREIGN KEY (`department_ID`) REFERENCES `Department`(`department_ID`)
);

CREATE TABLE IF NOT EXISTS `Course` (
  `course_ID` INT AUTO_INCREMENT,
  `course_code` VARCHAR(255) NOT NULL,
  `course_title` VARCHAR(255) NOT NULL,
  `units` TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (`course_ID`)
);

CREATE TABLE IF NOT EXISTS `Course_Section` (
  `course_ID` INT NOT NULL,
  `section_ID` INT NOT NULL,
  FOREIGN KEY (`course_ID`) REFERENCES `Course`(`course_ID`),
  FOREIGN KEY (`section_ID`) REFERENCES `Section`(`section_ID`)
);

CREATE TABLE IF NOT EXISTS `Schedule` (
  `schedule_ID` INT AUTO_INCREMENT,
  `section_ID` INT NOT NULL,
  `course_ID` INT NOT NULL,
  `faculty_ID` INT,
  `room_ID` INT,
  `day` ENUM('M', 'T', 'W', 'Th', 'F', 'S') NOT NULL,
  `start_time` TIME NOT NULL,
  `duration` DECIMAL NOT NULL,
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


-- ================================================
-- STORED PROCEDURES
-- ================================================

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

-- DUMMY DATA FOR TESTING=================================================================================================================

-- INSERT DUMMY DATA========================================
DELIMITER $$

CREATE PROCEDURE InsertAllData()
BEGIN
  INSERT INTO University (university_name) VALUES
  ('University A'),
  ('University B'),
  ('University C'),
  ('University D'),
  ('University E');
  
  INSERT INTO Campus (campus_name, university_ID) VALUES
  ('Campus A1', 1),
  ('Campus B1', 2),
  ('Campus C1', 3),
  ('Campus D1', 4),
  ('Campus E1', 5);
  
  INSERT INTO College (college_name, campus_ID) VALUES
  ('College A1', 1),
  ('College B1', 2),
  ('College C1', 3),
  ('College D1', 4),
  ('College E1', 5);
  
  INSERT INTO Department (department_name, college_ID) VALUES
  ('Department A1', 1),
  ('Department B1', 2),
  ('Department C1', 3),
  ('Department D1', 4),
  ('Department E1', 5);
  
  INSERT INTO Faculty (first_name, last_name, units, available_time_slots, birthdate, age, gender, contact_number, email, address) VALUES
  ('John', 'Doe', 3, 'MWF 9:00-12:00', '1985-03-25', 40, 'Male', '0917123456', 'john.doe@example.com', '123 Main St'),
  ('Jane', 'Smith', 4, 'TTh 10:00-1:00', '1987-04-15', 38, 'Female', '0917123457', 'jane.smith@example.com', '456 Oak St'),
  ('James', 'Brown', 3, 'MWF 1:00-4:00', '1990-07-20', 34, 'Male', '0917123458', 'james.brown@example.com', '789 Pine St'),
  ('Emily', 'Jones', 2, 'TTh 9:00-12:00', '1992-11-05', 32, 'Female', '0917123459', 'emily.jones@example.com', '101 Maple St'),
  ('Michael', 'Davis', 3, 'MWF 2:00-5:00', '1984-02-18', 41, 'Male', '0917123460', 'michael.davis@example.com', '202 Birch St');
  
  INSERT INTO Room (room_no, room_name, building_no, building_name, floor_no, college_ID) VALUES
  (101, 'Room A101', 1, 'Building A', 1, 1),
  (102, 'Room A102', 1, 'Building A', 1, 2),
  (201, 'Room B201', 2, 'Building B', 2, 3),
  (202, 'Room B202', 2, 'Building B', 2, 4),
  (301, 'Room C301', 3, 'Building C', 3, 5);
  
  INSERT INTO Section (section_name, department_ID) VALUES
  ('Section A1', 1),
  ('Section B1', 2),
  ('Section C1', 3),
  ('Section D1', 4),
  ('Section E1', 5);
  
  INSERT INTO Course (course_code, course_title, units, section_ID) VALUES
  ('CS101', 'Introduction to Computer Science', 3, 1),
  ('CS102', 'Data Structures', 3, 2),
  ('CS103', 'Algorithms', 3, 3),
  ('CS104', 'Software Engineering', 3, 4),
  ('CS105', 'Operating Systems', 3, 5);
  
  INSERT INTO Schedule (section_ID, course_ID, faculty_ID, room_ID, day, start_time, duration) VALUES
  (1, 1, 1, 1, 'M', '09:00:00', 60),
  (2, 2, 2, 2, 'T', '10:00:00', 60),
  (3, 3, 3, 3, 'W', '11:00:00', 60),
  (4, 4, 4, 4, 'Th', '14:00:00', 60),
  (5, 5, 5, 5, 'F', '13:00:00', 60);
  
END$$

-- DELETE DUMMY DATA===============================================================

-- Procedure to delete all dummy data from all tables
CREATE PROCEDURE DeleteAllData()
BEGIN
    DELETE FROM Schedule;

    DELETE FROM Course;

    DELETE FROM Section;

    DELETE FROM Room;

    DELETE FROM Faculty;

    DELETE FROM Department;

    DELETE FROM College;

    DELETE FROM Campus;

    DELETE FROM University;
END $$

-- SHOW ALL TABLES========================================

-- Procedure to display all dummy data from all tables
CREATE PROCEDURE ShowAllTables()
BEGIN
    SELECT * FROM Schedule;

    SELECT * FROM Course;

    SELECT * FROM Section;

    SELECT * FROM Room;

    SELECT * FROM Faculty;

    SELECT * FROM Department;

    SELECT * FROM College;

    SELECT * FROM Campus;

    SELECT * FROM University;
END $$

DELIMITER ;
