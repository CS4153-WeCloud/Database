-- Microservice-3 Database Schema
-- For Subscription & Trip Service (deployed on VM with VM MySQL)

-- Create database
CREATE DATABASE IF NOT EXISTS ms3_database
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE ms3_database;

-- Subscriptions table (semester subscriptions to routes)
CREATE TABLE IF NOT EXISTS subscriptions (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  userId BIGINT NOT NULL,
  routeId BIGINT NOT NULL,
  semester VARCHAR(50) NOT NULL,
  status ENUM('active', 'cancelled', 'expired', 'pending') NOT NULL DEFAULT 'active',
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_userId (userId),
  INDEX idx_routeId (routeId),
  INDEX idx_semester (semester),
  INDEX idx_status (status),
  UNIQUE KEY unique_user_route_semester (userId, routeId, semester)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Trips table (individual trip bookings)
CREATE TABLE IF NOT EXISTS trips (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  routeId BIGINT NOT NULL,
  subscriptionId BIGINT,
  userId BIGINT,
  date DATE NOT NULL,
  type ENUM('morning', 'evening') NOT NULL,
  status ENUM('scheduled', 'completed', 'cancelled', 'no-show') NOT NULL DEFAULT 'scheduled',
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_routeId (routeId),
  INDEX idx_subscriptionId (subscriptionId),
  INDEX idx_userId (userId),
  INDEX idx_date (date),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Notifications table (for email/SMS notifications)
CREATE TABLE IF NOT EXISTS notifications (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  userId BIGINT NOT NULL,
  type ENUM('email', 'sms', 'push') NOT NULL DEFAULT 'email',
  subject VARCHAR(255),
  message TEXT NOT NULL,
  status ENUM('pending', 'sent', 'failed') NOT NULL DEFAULT 'pending',
  sentAt TIMESTAMP NULL,
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_userId (userId),
  INDEX idx_status (status),
  INDEX idx_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- User notification preferences
CREATE TABLE IF NOT EXISTS notification_preferences (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  userId BIGINT NOT NULL UNIQUE,
  emailEnabled BOOLEAN NOT NULL DEFAULT TRUE,
  smsEnabled BOOLEAN NOT NULL DEFAULT FALSE,
  pushEnabled BOOLEAN NOT NULL DEFAULT FALSE,
  tripReminders BOOLEAN NOT NULL DEFAULT TRUE,
  routeUpdates BOOLEAN NOT NULL DEFAULT TRUE,
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_userId (userId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Sample subscriptions
INSERT INTO subscriptions (userId, routeId, semester, status) VALUES
(1, 1, 'Fall 2025', 'active'),
(1, 2, 'Fall 2025', 'active'),
(2, 2, 'Fall 2025', 'active'),
(3, 1, 'Fall 2025', 'cancelled'),
(3, 3, 'Fall 2025', 'active');

-- Sample trips
INSERT INTO trips (routeId, subscriptionId, userId, date, type, status) VALUES
(1, 1, 1, '2025-09-15', 'morning', 'scheduled'),
(1, 1, 1, '2025-09-15', 'evening', 'scheduled'),
(2, 2, 1, '2025-09-15', 'morning', 'scheduled'),
(2, 3, 2, '2025-09-16', 'morning', 'scheduled'),
(1, 1, 1, '2025-09-14', 'morning', 'completed'),
(1, 1, 1, '2025-09-14', 'evening', 'completed');

-- Sample notification preferences
INSERT INTO notification_preferences (userId, emailEnabled, smsEnabled, tripReminders, routeUpdates) VALUES
(1, TRUE, FALSE, TRUE, TRUE),
(2, TRUE, TRUE, TRUE, FALSE),
(3, TRUE, FALSE, FALSE, TRUE);

-- Quick stats
SELECT 'subscriptions' AS table_name, COUNT(*) AS record_count FROM subscriptions
UNION ALL SELECT 'trips', COUNT(*) FROM trips
UNION ALL SELECT 'notifications', COUNT(*) FROM notifications
UNION ALL SELECT 'notification_preferences', COUNT(*) FROM notification_preferences;

