-- User Service Database Schema
-- Supports Microservice-1 (Auth & User Service)
-- Deployed on Cloud Run with Cloud SQL

-- Create database
CREATE DATABASE IF NOT EXISTS user_service_db
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE user_service_db;

-- Users table (primary entity for /api/users)
-- Matches Microservice-1 User.js model expectations
CREATE TABLE IF NOT EXISTS users (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(128) NOT NULL UNIQUE,
  password_hash VARCHAR(255),
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  phone VARCHAR(20),
  status ENUM('active','inactive','suspended') NOT NULL DEFAULT 'active',
  role ENUM('student','staff','faculty','other') NOT NULL DEFAULT 'student',
  home_area VARCHAR(255),
  preferred_departure_time TIME,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_status (status),
  INDEX idx_role (role),
  INDEX idx_home_area (home_area),
  INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- User profiles (optional 1:1 extension)
CREATE TABLE IF NOT EXISTS user_profiles (
  profile_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL UNIQUE,
  avatar_url VARCHAR(500),
  bio TEXT,
  date_of_birth DATE,
  gender ENUM('male','female','other','prefer_not_to_say'),
  language VARCHAR(10) DEFAULT 'en',
  timezone VARCHAR(50),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- User addresses (optional 1:N extension)
CREATE TABLE IF NOT EXISTS user_addresses (
  address_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  address_type ENUM('home','work','billing','shipping') DEFAULT 'home',
  line1 VARCHAR(255) NOT NULL,
  line2 VARCHAR(255),
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100),
  zip_code VARCHAR(20),
  country VARCHAR(100) NOT NULL,
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_address_type (address_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Sample users for Columbia Point2Point Shuttle
INSERT INTO users (id, email, password_hash, first_name, last_name, phone, status, role, home_area, preferred_departure_time) VALUES
(1, 'alice@columbia.edu', '$2b$10$hashedpassword1', 'Alice', 'Johnson', '212-555-0101', 'active', 'student', 'Flushing, Queens', '08:00:00'),
(2, 'bob@columbia.edu', '$2b$10$hashedpassword2', 'Bob', 'Smith', '212-555-0102', 'active', 'staff', 'Jersey City, NJ', '07:45:00'),
(3, 'carol@columbia.edu', '$2b$10$hashedpassword3', 'Carol', 'Williams', '212-555-0103', 'active', 'faculty', 'Brooklyn Heights', '08:15:00'),
(4, 'demo@columbia.edu', '$2b$10$hashedpassword4', 'Demo', 'User', '212-555-0104', 'active', 'student', 'Astoria, Queens', '08:00:00'),
(5, 'test@columbia.edu', '$2b$10$hashedpassword5', 'Test', 'Account', NULL, 'inactive', 'other', NULL, NULL);

-- Sample profiles (optional)
INSERT INTO user_profiles (user_id, avatar_url, bio, date_of_birth, gender, language, timezone) VALUES
(1, NULL, 'CS graduate student', '2000-01-15', 'female', 'en', 'America/New_York'),
(2, NULL, 'Administrative staff', '1995-05-20', 'male', 'en', 'America/New_York'),
(3, NULL, 'Engineering professor', '1980-11-30', 'female', 'en', 'America/New_York');

-- Sample addresses (optional)
INSERT INTO user_addresses (user_id, address_type, line1, line2, city, state, zip_code, country, is_default) VALUES
(1, 'home', '123 Main St', 'Apt 4B', 'Flushing', 'NY', '11354', 'USA', TRUE),
(2, 'home', '456 Jersey Ave', NULL, 'Jersey City', 'NJ', '07302', 'USA', TRUE),
(3, 'home', '789 Brooklyn Ave', 'Suite 100', 'Brooklyn', 'NY', '11201', 'USA', TRUE);

-- Quick stats
SELECT 'users' AS table_name, COUNT(*) AS record_count FROM users
UNION ALL SELECT 'user_profiles', COUNT(*) FROM user_profiles
UNION ALL SELECT 'user_addresses', COUNT(*) FROM user_addresses;
