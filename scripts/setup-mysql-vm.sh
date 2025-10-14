#!/bin/bash

# Setup MySQL on GCP VM
# Run this script on your MySQL VM after creating it

echo "=== MySQL VM Setup Script ==="
echo "This script will install and configure MySQL on Ubuntu"

# Update system
echo "Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install MySQL Server
echo "Installing MySQL Server..."
sudo apt-get install mysql-server -y

# Start MySQL service
echo "Starting MySQL service..."
sudo systemctl start mysql
sudo systemctl enable mysql

# Secure MySQL installation (automated)
echo "Securing MySQL installation..."
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'ChangeThisPassword123!';"
sudo mysql -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
sudo mysql -e "DROP DATABASE IF EXISTS test;"
sudo mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Configure MySQL for remote access
echo "Configuring MySQL for remote access..."
sudo sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

# Create application user
echo "Creating application user..."
sudo mysql -uroot -pChangeThisPassword123! <<MYSQL_SCRIPT
CREATE USER IF NOT EXISTS 'appuser'@'%' IDENTIFIED BY 'AppPassword123!';
GRANT ALL PRIVILEGES ON user_service_db.* TO 'appuser'@'%';
GRANT ALL PRIVILEGES ON order_service_db.* TO 'appuser'@'%';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Restart MySQL
echo "Restarting MySQL..."
sudo systemctl restart mysql

# Show MySQL status
echo "MySQL Status:"
sudo systemctl status mysql --no-pager

# Show MySQL version
echo ""
echo "MySQL Version:"
mysql --version

echo ""
echo "=== MySQL Setup Complete ==="
echo "Root password: ChangeThisPassword123!"
echo "App user: appuser"
echo "App password: AppPassword123!"
echo ""
echo "⚠️  IMPORTANT: Change these default passwords in production!"
echo ""
echo "Next steps:"
echo "1. Load database schemas: mysql -u appuser -p < schema/user_service_schema.sql"
echo "2. Configure firewall to allow internal connections"
echo "3. Update microservice .env files with MySQL VM internal IP"
echo ""
echo "Internal IP: $(hostname -I | awk '{print $1}')"

