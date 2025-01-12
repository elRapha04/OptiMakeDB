CREATE TABLE Course (
  course_ID INT PRIMARY KEY,
  course_code VARCHAR(255),
  course_title VARCHAR(255),
  units INT,
  section_ID INT
);

CREATE TABLE Faculty (
  faculty_ID INT PRIMARY KEY,
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  units INT,
  available_time_slots TIME, -- verifu type
  birthdate DATE,
  age INT,
  gender ENUM('Male', 'Female', 'Other'),
  contact_number VARCHAR(255),
  email VARCHAR(255),
  address VARCHAR(255)
);

CREATE TABLE University (
  university_ID INT PRIMARY KEY,
  university_name VARCHAR(255)
);

CREATE TABLE Campus (
  campus_ID INT PRIMARY KEY,
  campus_name VARCHAR(255),
  university_ID INT,
  FOREIGN KEY (university_ID) REFERENCES University(university_ID)
);

CREATE TABLE College (
  college_ID INT PRIMARY KEY,
  college_name VARCHAR(255),
  campus_ID INT,
  FOREIGN KEY (campus_ID) REFERENCES Campus(campus_ID)
);

CREATE TABLE Room (
  room_ID INT PRIMARY KEY,
  room_name VARCHAR(255),
  building_no INT,
  floor_no INT,
  college_ID INT,
  FOREIGN KEY (college_ID) REFERENCES College(college_ID)
);

CREATE TABLE Department (
  department_ID INT PRIMARY KEY,
  department_name VARCHAR(255),
  college_ID INT,
  FOREIGN KEY (college_ID) REFERENCES College(college_ID)
);

CREATE TABLE Section (
  section_ID INT PRIMARY KEY,
  section_name VARCHAR(255),
  department_ID INT,
  FOREIGN KEY (department_ID) REFERENCES Department(department_ID)
);

CREATE TABLE Schedule (
  schedule_ID INT PRIMARY KEY,
  section_ID INT,
  course_ID INT,
  faculty_ID INT,
  room_ID INT,
  day ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'),
  start_time TIME,
  duration INT,
  FOREIGN KEY (course_ID) REFERENCES Course(course_ID),
  FOREIGN KEY (faculty_ID) REFERENCES Faculty(faculty_ID),
  FOREIGN KEY (room_ID) REFERENCES Room(room_ID),
  FOREIGN KEY (section_ID) REFERENCES Section(section_ID)
);
