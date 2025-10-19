-- User Service Database Schema
-- Supports the User Service microservice 

-- Create database
CREATE DATABASE IF NOT EXISTS user_service_db
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE user_service_db;

-- Users table (primary entity read by /api/users)
-- Note: first/last/phone are optional; service needs email/status/timestamps
CREATE TABLE IF NOT EXISTS users (
  user_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(128) NOT NULL UNIQUE,
  password_hash VARCHAR(255),
  first_name VARCHAR(100),
  last_name  VARCHAR(100),
  phone VARCHAR(20),
  status ENUM('active','inactive','suspended') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_status (status),
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
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- User addresses (optional 1:N extension)
CREATE TABLE IF NOT EXISTS user_addresses (
  address_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  address_type ENUM('home','work','billing','shipping') DEFAULT 'home',
  line1 VARCHAR(255) NOT NULL,
  line2 VARCHAR(255),
  city  VARCHAR(100) NOT NULL,
  state VARCHAR(100),
  zip_code VARCHAR(20),
  country VARCHAR(100) NOT NULL,
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_address_type (address_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Sample users (matches local demo for /api/users)
INSERT INTO users (user_id, email, password_hash, status, first_name, last_name, phone) VALUES
(101,'alice@example.com','$2y$hashA','active',   NULL,NULL,NULL),
(102,'bob@example.com',  '$2y$hashB','active',   NULL,NULL,NULL),
(103,'carol@example.com','$2y$hashC','inactive', NULL,NULL,NULL);

-- Sample profiles (optional)
INSERT INTO user_profiles (user_id, avatar_url, bio, date_of_birth, gender, language, timezone) VALUES
(101, NULL, 'CS student', '2002-01-10', 'female', 'en', 'America/New_York'),
(102, NULL, 'TA',         '2001-05-20', 'male',   'en', 'America/New_York');

-- Sample addresses (optional)
INSERT INTO user_addresses (user_id, address_type, line1, line2, city, state, zip_code, country, is_default) VALUES
(101,'home','123 Broadway', NULL,        'New York','NY','10027','USA', TRUE),
(101,'work','1 Centre St',  NULL,        'New York','NY','10007','USA', FALSE),
(102,'home','77 5th Ave',   'Apt 5B',    'New York','NY','10011','USA', TRUE);

-- Quick stats
SELECT 'users' AS table_name, COUNT(*) AS record_count FROM users
UNION ALL SELECT 'user_profiles',  COUNT(*) FROM user_profiles
UNION ALL SELECT 'user_addresses', COUNT(*) FROM user_addresses;
