/* 
TODOS:
- hash table
- Sync with schema
- accounts link
- dedic/shared building
  - Normalize
  - funcs and procedures
  - data types
  - on delete
*/

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
  `faculty_ID` INT AUTO_INCREMENT,
  `first_name` VARCHAR(255) NOT NULL,
  `last_name` VARCHAR(255) NOT NULL,
  `units` TINYINT UNSIGNED NOT NULL,
  `birthdate` DATE NOT NULL,
  `age` TINYINT UNSIGNED NOT NULL,
  `gender` ENUM('Male', 'Female', 'Other') NOT NULL,
  `contact_number` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) UNIQUE NOT NULL,
  PRIMARY KEY (`faculty_ID`)
);

CREATE TABLE IF NOT EXISTS `Faculty_Availability`(
  `faculty_ID` INT,
  `day` ENUM('M', 'T', 'W', 'Th', 'F', 'S') NOT NULL,
  `start_time` TIME NOT NULL,
  `duration` DECIMAL NOT NULL,
  `end_time` TIME NOT NULL,
  FOREIGN KEY (`faculty_ID`) REFERENCES `Faculty`(`faculty_ID`)
);

CREATE TABLE IF NOT EXISTS `Administrator` (
  `admin_ID` INT AUTO_INCREMENT,
  `account_ID` INT NOT NULL,
  `university_ID` INT NOT NULL,
  `campus_ID` INT NOT NULL,
  PRIMARY KEY (`admin_ID`),
  FOREIGN KEY (`account_ID`) REFERENCES `Account`(`account_ID`),
  FOREIGN KEY (`university_ID`) REFERENCES `University`(`university_ID`),
  FOREIGN KEY (`campus_ID`) REFERENCES `Campus`(`campus_ID`)
);

CREATE TABLE IF NOT EXISTS `Dean` (
  `dean_ID` INT AUTO_INCREMENT,
  `college_ID` INT NOT NULL,
  `account_ID` INT NOT NULL,
  `university_ID` INT NOT NULL,
  `campus_ID` INT NOT NULL,
  PRIMARY KEY (`dean_ID`),
  FOREIGN KEY (`college_ID`) REFERENCES `College`(`college_ID`)
  FOREIGN KEY (`account_ID`) REFERENCES `Account`(`account_ID`),
  FOREIGN KEY (`university_ID`) REFERENCES `University`(`university_ID`),
  FOREIGN KEY (`campus_ID`) REFERENCES `Campus`(`campus_ID`)
);

CREATE TABLE IF NOT EXISTS `Chairperson` (
  `chairperson_ID` INT AUTO_INCREMENT,
  `department_ID` INT NOT NULL,
  `account_ID` INT NOT NULL,
  `university_ID` INT NOT NULL,
  `campus_ID` INT NOT NULL,
  `college_ID` INT NOT NULL,
  PRIMARY KEY (`chairperson_ID`),
  FOREIGN KEY (`department_ID`) REFERENCES `Department`(`department_ID`)
  FOREIGN KEY (`account_ID`) REFERENCES `Account`(`account_ID`),
  FOREIGN KEY (`university_ID`) REFERENCES `University`(`university_ID`),
  FOREIGN KEY (`campus_ID`) REFERENCES `Campus`(`campus_ID`),
  FOREIGN KEY (`college_ID`) REFERENCES `College`(`college_ID`)
);

CREATE TABLE IF NOT EXISTS `Account` (
  `account_ID` INT AUTO_INCREMENT,
  `username` VARCHAR(255) UNIQUE NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `role` ENUM('Administrator', 'Dean', 'Chairperson') NOT NULL,
  `first_name` VARCHAR(255) NOT NULL,
  `last_name` VARCHAR(255) NOT NULL,
  `birthdate` DATE NOT NULL,
  `age` TINYINT UNSIGNED NOT NULL,
  `gender` ENUM('Male', 'Female', 'Other') NOT NULL,
  `contact_number` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) UNIQUE NOT NULL,
  PRIMARY KEY (`account_ID`)
);

CREATE TABLE IF NOT EXISTS `Hash` (
  `hash_ID` INT AUTO_INCREMENT,
  `account_ID` INT NOT NULL,
  `issued_by` INT NOT NULL,
  `role` ENUM('Administrator', 'Dean', 'Chairperson') NOT NULL,
  `hash` VARCHAR(255) NOT NULL,
  `status` ENUM('Enabled', 'Disabled') DEFAULT 'Enabled',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`account_ID`) REFERENCES `Account`(`account_ID`) ON DELETE CASCADE,
  FOREIGN KEY (`issued_by`) REFERENCES `Account`(`account_ID`) ON DELETE SET NULL,
  PRIMARY KEY (`hash_ID`)
);

CREATE TABLE IF NOT EXISTS `Building` (
  `building_ID` INT AUTO_INCREMENT,
  `building_no` INT UNSIGNED,
  `building_name` VARCHAR,
  `college_ID` INT,
  `latitude` DECIMAL(9,6),
  `longitude` DECIMAL(9,6),
  PRIMARY KEY (`building_ID`),
  FOREIGN KEY (`college_ID`) REFERENCES `College`(`college_ID`)
);

CREATE TABLE IF NOT EXISTS `Apparatus` (
  `apparatus_ID` INT AUTO_INCREMENT,
  `apparatus_name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`apparatus_ID`)
);

CREATE TABLE IF NOT EXISTS `Room` (
  `room_ID` INT AUTO_INCREMENT,
  `room_no` INT UNSIGNED NOT NULL,
  `room_name` VARCHAR(255),
  `building_ID` INT NOT NULL,
  `floor_no` TINYINT UNSIGNED NOT NULL,
  `apparatus_ID` INT,
  PRIMARY KEY (`room_ID`),
  FOREIGN KEY (`apparatus_ID`) REFERENCES `Apparatus`(`apparatus_ID`),
  FOREIGN KEY (`building_ID`) REFERENCES `Building`(`building_ID`)
);

CREATE TABLE IF NOT EXISTS `Section` (
  `section_ID` INT AUTO_INCREMENT,
  `section_name` VARCHAR(255) NOT NULL,
  `year_level` ENUM('1st', '2nd', '3rd', '4th', '5th') NOT NULL,
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
  `course_code` VARCHAR(255) UNIQUE NOT NULL,
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
  `end_time` TIME NOT NULL,
  PRIMARY KEY (`schedule_ID`),
  FOREIGN KEY (`section_ID`) REFERENCES `Section`(`section_ID`),
  FOREIGN KEY (`course_ID`) REFERENCES `Course`(`course_ID`),
  FOREIGN KEY (`faculty_ID`) REFERENCES `Faculty`(`faculty_ID`),
  FOREIGN KEY (`room_ID`) REFERENCES `Room`(`room_ID`)
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

-- Function: Calculate Age based on birthdate
CREATE FUNCTION CalculateAge(birthdate DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, birthdate, CURDATE());
END $$

-- Function: Calculate End Time of a session
CREATE FUNCTION CalculateEndTime(start_time TIME, duration INT)
RETURNS TIME
DETERMINISTIC
BEGIN
    RETURN ADDTIME(start_time, SEC_TO_TIME(duration * 60));
END $$

-- Function: Check Faculty Availability
CREATE FUNCTION CheckFacultyAvailability(faculty_ID INT, day ENUM('M', 'T', 'W', 'Th', 'F', 'S'), start_time TIME, duration INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    RETURN NOT EXISTS (
        SELECT 1 FROM Schedule
        WHERE faculty_ID = faculty_ID AND day = day
        AND (start_time < CalculateEndTime(start_time, duration) AND CalculateEndTime(start_time, duration) > start_time)
    );
END $$

-- Function: Check Room Availability
CREATE FUNCTION CheckRoomAvailability(room_ID INT, day ENUM('M', 'T', 'W', 'Th', 'F', 'S'), start_time TIME, duration INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    RETURN NOT EXISTS (
        SELECT 1 FROM Schedule
        WHERE room_ID = room_ID AND day = day
        AND (start_time < CalculateEndTime(start_time, duration) AND CalculateEndTime(start_time, duration) > start_time)
    );
END $$

-- Function: Validate Course Section Schedule
CREATE FUNCTION ValidateCourseSectionSchedule(section_ID INT, faculty_ID INT, day ENUM('M', 'T', 'W', 'Th', 'F', 'S'), start_time TIME, duration INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    RETURN NOT EXISTS (
        SELECT 1 FROM Schedule
        WHERE faculty_ID = faculty_ID AND day = day
        AND (start_time < CalculateEndTime(start_time, duration) AND CalculateEndTime(start_time, duration) > start_time)
    );
END $$

-- ================================================
-- STORED PROCEDURES
-- ================================================

-- Procedure: Create New Account
CREATE PROCEDURE CreateNewAccount(IN username VARCHAR(255), IN password_hash VARCHAR(255), IN role ENUM('Admin', 'Dean', 'Chairperson'))
BEGIN
    INSERT INTO Users (username, password_hash, role)
    VALUES (username, password_hash, role);
END $$

-- Procedure: Authenticate User
CREATE PROCEDURE AuthenticateUser(IN username VARCHAR(255), IN input_password VARCHAR(255), OUT isAuthenticated BOOLEAN)
BEGIN
    DECLARE stored_hash VARCHAR(255);
    SELECT password_hash INTO stored_hash FROM Users WHERE username = username;
    SET isAuthenticated = (stored_hash = input_password);
END $$

-- Procedure: Change User Password
CREATE PROCEDURE ChangeUserPassword(IN username VARCHAR(255), IN new_password_hash VARCHAR(255))
BEGIN
    UPDATE Users SET password_hash = new_password_hash WHERE username = username;
END $$

-- Procedure: Assign Faculty to Schedule
CREATE PROCEDURE AssignFacultyToSchedule(IN faculty_ID INT, IN schedule_ID INT)
BEGIN
    IF CheckFacultyAvailability(faculty_ID, (SELECT day FROM Schedule WHERE schedule_ID = schedule_ID),
                                (SELECT start_time FROM Schedule WHERE schedule_ID = schedule_ID),
                                (SELECT duration FROM Schedule WHERE schedule_ID = schedule_ID)) THEN
        UPDATE Schedule SET faculty_ID = faculty_ID WHERE schedule_ID = schedule_ID;
    END IF;
END $$

-- Procedure: Get Faculty Schedule
CREATE PROCEDURE GetFacultySchedule(IN faculty_ID INT)
BEGIN
    SELECT * FROM Schedule WHERE faculty_ID = faculty_ID;
END $$

-- Procedure: Add New Faculty Member
CREATE PROCEDURE AddNewFacultyMember(IN name VARCHAR(255), IN department_ID INT, IN birthdate DATE, IN contact_info VARCHAR(255))
BEGIN
    INSERT INTO Faculty (name, department_ID, birthdate, contact_info)
    VALUES (name, department_ID, birthdate, contact_info);
END $$

-- Procedure: Update Faculty Information
CREATE PROCEDURE UpdateFacultyInformation(IN faculty_ID INT, IN contact_info VARCHAR(255), IN department_ID INT)
BEGIN
    UPDATE Faculty
    SET contact_info = contact_info, department_ID = department_ID
    WHERE faculty_ID = faculty_ID;
END $$

-- Procedure: Delete Faculty Record
CREATE PROCEDURE DeleteFacultyRecord(IN faculty_ID INT)
BEGIN
    DELETE FROM Faculty WHERE faculty_ID = faculty_ID;
END $$

-- Procedure: List Faculty by Department
CREATE PROCEDURE ListFacultyByDepartment(IN department_ID INT)
BEGIN
    SELECT * FROM Faculty WHERE department_ID = department_ID;
END $$

-- Procedure: List Available Rooms
CREATE PROCEDURE ListAvailableRooms(IN day ENUM('M', 'T', 'W', 'Th', 'F', 'S'), IN start_time TIME, IN duration INT)
BEGIN
    SELECT * FROM Room WHERE room_ID NOT IN (
        SELECT room_ID FROM Schedule WHERE day = day
        AND (start_time < CalculateEndTime(start_time, duration) AND CalculateEndTime(start_time, duration) > start_time)
    );
END $$

DELIMITER ;

-- DUMMY DATA FOR TESTING=================================================================================================================

-- INSERT DUMMY DATA========================================
DELIMITER $$

CREATE PROCEDURE InsertAllData()
BEGIN
    -- Insert into University
    INSERT INTO University (university_name) VALUES
    ('University A'), ('University B'), ('University C'), ('University D'), ('University E');
    
    -- Insert into Campus
    INSERT INTO Campus (campus_name, university_ID, latitude, longitude) VALUES
    ('Campus A1', 1, 8.4772, 124.6450),
    ('Campus B1', 2, 8.4773, 124.6451),
    ('Campus C1', 3, 8.4774, 124.6452),
    ('Campus D1', 4, 8.4775, 124.6453),
    ('Campus E1', 5, 8.4776, 124.6454);
    
    -- Insert into College
    INSERT INTO College (college_name, campus_ID) VALUES
    ('College of Science', 1), ('College of Engineering', 2), ('College of Arts', 3), ('College of Business', 4), ('College of Education', 5);
    
    -- Insert into Department
    INSERT INTO Department (department_name, college_ID) VALUES
    ('Computer Science', 1), ('Electrical Engineering', 2), ('Fine Arts', 3), ('Marketing', 4), ('Secondary Education', 5);
    
    -- Insert into Faculty
    INSERT INTO Faculty (first_name, last_name, units, birthdate, age, gender, contact_number, email) VALUES
    ('John', 'Doe', 12, '1980-05-15', 44, 'Male', '09171234567', 'john.doe@example.com'),
    ('Jane', 'Smith', 15, '1985-08-22', 39, 'Female', '09172345678', 'jane.smith@example.com');
    
    -- Insert into Faculty_Availability
    INSERT INTO Faculty_Availability (faculty_ID, day, start_time, duration, end_time) VALUES
    (1, 'M', '08:00:00', 1.5, '09:30:00'),
    (2, 'T', '10:00:00', 2, '12:00:00');
    
    -- Insert into Account
    INSERT INTO Account (username, password, role, first_name, last_name, birthdate, age, gender, contact_number, email) VALUES
    ('admin1', 'pass123', 'Administrator', 'Alice', 'Johnson', '1988-10-10', 36, 'Female', '09173456789', 'alice.johnson@example.com');
    
    -- Insert into Administrator
    INSERT INTO Administrator (account_ID, university_ID, campus_ID) VALUES (1, 1, 1);
    
    -- Insert into Building
    INSERT INTO Building (building_no, building_name, college_ID, latitude, longitude) VALUES
    (1, 'Science Building', 1, 8.4780, 124.6460);
    
    -- Insert into Apparatus
    INSERT INTO Apparatus (apparatus_name) VALUES ('Projector');
    
    -- Insert into Room
    INSERT INTO Room (room_no, room_name, building_ID, floor_no, apparatus_ID) VALUES
    (101, 'Lab A1', 1, 1, 1);
    
    -- Insert into Section
    INSERT INTO Section (section_name, year_level, university_ID, campus_ID, college_ID, department_ID) VALUES
    ('CS 1-A', '1st', 1, 1, 1, 1);
    
    -- Insert into Course
    INSERT INTO Course (course_code, course_title, units) VALUES
    ('CS101', 'Introduction to Computer Science', 3);
    
    -- Insert into Course_Section
    INSERT INTO Course_Section (course_ID, section_ID) VALUES (1, 1);
    
    -- Insert into Schedule
    INSERT INTO Schedule (section_ID, course_ID, faculty_ID, room_ID, day, start_time, duration, end_time) VALUES
    (1, 1, 1, 1, 'M', '09:30:00', 1.5, '11:00:00');
END $$


-- DELETE DUMMY DATA===============================================================

-- Procedure to delete all dummy data from all tables
CREATE PROCEDURE DeleteAllData()
BEGIN
    DELETE FROM Schedule;
    DELETE FROM Course_Section;
    DELETE FROM Course;
    DELETE FROM Section;
    DELETE FROM Room;
    DELETE FROM Apparatus;
    DELETE FROM Building;
    DELETE FROM Faculty_Availability;
    DELETE FROM Faculty;
    DELETE FROM Department;
    DELETE FROM College;
    DELETE FROM Campus;
    DELETE FROM University;
    DELETE FROM Account;
    DELETE FROM Administrator;
END $$

-- DISPLAY DUMMY DATA===============================================================
CREATE PROCEDURE ShowAllTables()
BEGIN
    SELECT * FROM University;
    SELECT * FROM Campus;
    SELECT * FROM College;
    SELECT * FROM Department;
    SELECT * FROM Faculty;
    SELECT * FROM Faculty_Availability;
    SELECT * FROM Account;
    SELECT * FROM Administrator;
    SELECT * FROM Building;
    SELECT * FROM Apparatus;
    SELECT * FROM Room;
    SELECT * FROM Section;
    SELECT * FROM Course;
    SELECT * FROM Course_Section;
    SELECT * FROM Schedule;
END $$

DELIMITER ;