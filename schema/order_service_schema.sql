-- Order Service Database Schema (Optional)
-- This schema can be used if Order Service needs persistent storage

-- Create database
CREATE DATABASE IF NOT EXISTS order_service_db;
USE order_service_db;

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
    id VARCHAR(36) PRIMARY KEY,  -- UUID
    user_id INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Order items table
CREATE TABLE IF NOT EXISTS order_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id VARCHAR(36) NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_order_id (order_id),
    INDEX idx_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Shipping addresses table
CREATE TABLE IF NOT EXISTS shipping_addresses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id VARCHAR(36) NOT NULL UNIQUE,
    street VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    zip_code VARCHAR(20),
    country VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_order_id (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sample data
INSERT INTO orders (id, user_id, total_amount, status) VALUES
('123e4567-e89b-12d3-a456-426614174001', 1, 999.99, 'delivered'),
('123e4567-e89b-12d3-a456-426614174002', 1, 139.97, 'processing'),
('123e4567-e89b-12d3-a456-426614174003', 2, 299.99, 'shipped');

INSERT INTO order_items (order_id, product_id, product_name, quantity, price) VALUES
('123e4567-e89b-12d3-a456-426614174001', 'PROD-001', 'Laptop', 1, 999.99),
('123e4567-e89b-12d3-a456-426614174002', 'PROD-002', 'Mouse', 2, 29.99),
('123e4567-e89b-12d3-a456-426614174002', 'PROD-003', 'Keyboard', 1, 79.99),
('123e4567-e89b-12d3-a456-426614174003', 'PROD-004', 'Monitor', 1, 299.99);

INSERT INTO shipping_addresses (order_id, street, city, state, zip_code, country) VALUES
('123e4567-e89b-12d3-a456-426614174001', '123 Main St', 'San Francisco', 'CA', '94102', 'USA'),
('123e4567-e89b-12d3-a456-426614174002', '123 Main St', 'San Francisco', 'CA', '94102', 'USA'),
('123e4567-e89b-12d3-a456-426614174003', '789 Oak Ave', 'Los Angeles', 'CA', '90001', 'USA');

