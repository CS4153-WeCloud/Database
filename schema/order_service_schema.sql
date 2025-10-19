-- Order Service Database Schema (Optional)
-- Use this schema if the Order Service needs persistent storage

-- Create database 
CREATE DATABASE IF NOT EXISTS order_service_db
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE order_service_db;

-- Orders table (one row per order; UUID primary key)
CREATE TABLE IF NOT EXISTS orders (
  order_id CHAR(36) PRIMARY KEY,                       -- UUID
  user_id  BIGINT NOT NULL,                            -- logical link to user_service_db.users.user_id
  total_amount DECIMAL(10,2) NOT NULL,
  status ENUM('pending','confirmed','processing','shipped','delivered','cancelled')
         NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_user_id (user_id),
  INDEX idx_status (status),
  INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Order items table (N rows per order; price is unit-price snapshot)
CREATE TABLE IF NOT EXISTS order_items (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  order_id CHAR(36) NOT NULL,
  product_id VARCHAR(50) NOT NULL,
  product_name VARCHAR(255) NOT NULL,
  quantity INT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
  INDEX idx_order_id (order_id),
  INDEX idx_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Shipping addresses table (1:1 with orders; snapshot of address at purchase time)
CREATE TABLE IF NOT EXISTS shipping_addresses (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  order_id CHAR(36) NOT NULL UNIQUE,
  street   VARCHAR(255) NOT NULL,
  city     VARCHAR(100) NOT NULL,
  state    VARCHAR(100),
  zip_code VARCHAR(20),
  country  VARCHAR(100) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
  INDEX idx_order_id (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Sample data (orders)
INSERT INTO orders (order_id, user_id, total_amount, status) VALUES
('123e4567-e89b-12d3-a456-426614174001', 1, 999.99, 'delivered'),
('123e4567-e89b-12d3-a456-426614174002', 1, 139.97, 'processing'),
('123e4567-e89b-12d3-a456-426614174003', 2, 299.99, 'shipped');

-- Sample data (order items)
INSERT INTO order_items (order_id, product_id, product_name, quantity, price) VALUES
('123e4567-e89b-12d3-a456-426614174001', 'PROD-001', 'Laptop',   1, 999.99),
('123e4567-e89b-12d3-a456-426614174002', 'PROD-002', 'Mouse',    2,  29.99),
('123e4567-e89b-12d3-a456-426614174002', 'PROD-003', 'Keyboard', 1,  79.99),
('123e4567-e89b-12d3-a456-426614174003', 'PROD-004', 'Monitor',  1, 299.99);

-- Sample data (shipping addresses)
INSERT INTO shipping_addresses (order_id, street, city, state, zip_code, country) VALUES
('123e4567-e89b-12d3-a456-426614174001', '123 Main St', 'San Francisco', 'CA', '94102', 'USA'),
('123e4567-e89b-12d3-a456-426614174002', '123 Main St', 'San Francisco', 'CA', '94102', 'USA'),
('123e4567-e89b-12d3-a456-426614174003', '789 Oak Ave', 'Los Angeles',   'CA', '90001', 'USA');
