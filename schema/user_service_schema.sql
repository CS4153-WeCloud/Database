-- User Service Database Schema
-- This schema supports the User Service microservice

-- Create database
CREATE DATABASE IF NOT EXISTS user_service_db;
USE user_service_db;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User profiles table (optional extension)
CREATE TABLE IF NOT EXISTS user_profiles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    avatar_url VARCHAR(500),
    bio TEXT,
    date_of_birth DATE,
    gender ENUM('male', 'female', 'other', 'prefer_not_to_say'),
    language VARCHAR(10) DEFAULT 'en',
    timezone VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User addresses table (optional extension)
CREATE TABLE IF NOT EXISTS user_addresses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    address_type ENUM('home', 'work', 'billing', 'shipping') DEFAULT 'home',
    street VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    zip_code VARCHAR(20),
    country VARCHAR(100) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_address_type (address_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert sample data
INSERT INTO users (email, first_name, last_name, phone, status) VALUES
('john.doe@example.com', 'John', 'Doe', '+1234567890', 'active'),
('jane.smith@example.com', 'Jane', 'Smith', '+1234567891', 'active'),
('bob.wilson@example.com', 'Bob', 'Wilson', '+1234567892', 'active'),
('alice.brown@example.com', 'Alice', 'Brown', '+1234567893', 'inactive');

-- Insert sample profiles
INSERT INTO user_profiles (user_id, bio, date_of_birth, gender, language, timezone) VALUES
(1, 'Software developer passionate about building great products', '1990-05-15', 'male', 'en', 'America/New_York'),
(2, 'Product manager with 10 years of experience', '1985-08-22', 'female', 'en', 'America/Los_Angeles');

-- Insert sample addresses
INSERT INTO user_addresses (user_id, address_type, street, city, state, zip_code, country, is_default) VALUES
(1, 'home', '123 Main St', 'San Francisco', 'CA', '94102', 'USA', TRUE),
(1, 'work', '456 Market St', 'San Francisco', 'CA', '94103', 'USA', FALSE),
(2, 'home', '789 Oak Ave', 'Los Angeles', 'CA', '90001', 'USA', TRUE);

-- Show table statistics
SELECT 'Users' AS table_name, COUNT(*) AS record_count FROM users
UNION ALL
SELECT 'User Profiles', COUNT(*) FROM user_profiles
UNION ALL
SELECT 'User Addresses', COUNT(*) FROM user_addresses;

