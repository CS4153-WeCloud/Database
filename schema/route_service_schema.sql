-- Route Service Database Schema
-- For Microservice-2 (Route & Group Service)

-- Create database
CREATE DATABASE IF NOT EXISTS route_service_db
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE route_service_db;

-- Routes table (main entity)
CREATE TABLE IF NOT EXISTS routes (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  from_location VARCHAR(255) NOT NULL,
  to_location VARCHAR(255) NOT NULL,
  status ENUM('proposed', 'active', 'completed', 'cancelled') NOT NULL DEFAULT 'proposed',
  schedule_days JSON NOT NULL,
  morning_time TIME NOT NULL,
  evening_time TIME NOT NULL,
  semester VARCHAR(50) NOT NULL,
  current_members INT NOT NULL DEFAULT 0,
  required_members INT NOT NULL DEFAULT 15,
  estimated_cost DECIMAL(10,2),
  description TEXT,
  created_by BIGINT NOT NULL,
  version INT NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_status (status),
  INDEX idx_semester (semester),
  INDEX idx_created_by (created_by),
  INDEX idx_from_to (from_location, to_location)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Route members table (many-to-many relationship)
CREATE TABLE IF NOT EXISTS route_members (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  route_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL,
  status ENUM('pending', 'confirmed', 'cancelled') NOT NULL DEFAULT 'confirmed',
  joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE,
  UNIQUE KEY unique_route_user (route_id, user_id),
  INDEX idx_route_id (route_id),
  INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Users table (local copy for FK validation and member details)
-- Note: This is a denormalized copy synced from Auth Service
CREATE TABLE IF NOT EXISTS users (
  id BIGINT PRIMARY KEY,
  email VARCHAR(128) NOT NULL,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  home_area VARCHAR(255),
  status ENUM('active', 'inactive', 'suspended') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Sample data for routes
INSERT INTO routes (from_location, to_location, schedule_days, morning_time, evening_time, semester, current_members, required_members, estimated_cost, description, created_by) VALUES
('Columbia University', 'Flushing, Queens', '["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]', '08:00:00', '18:30:00', 'Fall 2025', 8, 15, 120.00, 'Daily commuter shuttle from Columbia to Flushing area', 1),
('Columbia University', 'Jersey City, NJ', '["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]', '07:45:00', '18:15:00', 'Fall 2025', 17, 20, 150.00, 'Daily commuter shuttle from Columbia to Jersey City', 2),
('Columbia University', 'Brooklyn Heights', '["Monday", "Wednesday", "Friday"]', '08:15:00', '18:45:00', 'Fall 2025', 4, 12, 100.00, 'MWF shuttle to Brooklyn Heights', 3);

-- Update first route to 'active' for demonstration
UPDATE routes SET status = 'active' WHERE id = 2;

-- Sample users (for local FK validation)
INSERT INTO users (id, email, first_name, last_name, home_area, status) VALUES
(1, 'alice@columbia.edu', 'Alice', 'Johnson', 'Flushing, Queens', 'active'),
(2, 'bob@columbia.edu', 'Bob', 'Smith', 'Jersey City, NJ', 'active'),
(3, 'carol@columbia.edu', 'Carol', 'Williams', 'Brooklyn Heights', 'active');

-- Sample route members
INSERT INTO route_members (route_id, user_id) VALUES
(1, 1), (1, 2),
(2, 2), (2, 3),
(3, 1), (3, 3);

-- Quick stats
SELECT 'routes' AS table_name, COUNT(*) AS record_count FROM routes
UNION ALL SELECT 'route_members', COUNT(*) FROM route_members
UNION ALL SELECT 'users', COUNT(*) FROM users;

