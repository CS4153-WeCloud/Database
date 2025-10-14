#!/bin/bash

# Test MySQL connection from microservice VM
# Run this script on your microservice VM to verify database connectivity

echo "=== MySQL Connection Test ==="

# Configuration
MYSQL_HOST="${MYSQL_HOST:-10.128.0.2}"  # Replace with your MySQL VM internal IP
MYSQL_USER="${MYSQL_USER:-appuser}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-AppPassword123!}"
MYSQL_DATABASE="${MYSQL_DATABASE:-user_service_db}"

echo "Testing connection to MySQL..."
echo "Host: $MYSQL_HOST"
echo "User: $MYSQL_USER"
echo "Database: $MYSQL_DATABASE"
echo ""

# Test connection
mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -e "SELECT 'Connection successful!' AS status, NOW() AS timestamp;"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ MySQL connection successful!"
    
    # Query some data
    echo ""
    echo "Sample users:"
    mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -e "SELECT id, email, first_name, last_name, status FROM users LIMIT 3;"
else
    echo ""
    echo "❌ MySQL connection failed!"
    echo ""
    echo "Troubleshooting:"
    echo "1. Check if MySQL VM is running: gcloud compute instances list"
    echo "2. Verify internal IP is correct"
    echo "3. Check firewall rules allow internal traffic"
    echo "4. Verify MySQL user has correct permissions"
    echo "5. Check if MySQL is configured for remote connections (bind-address = 0.0.0.0)"
fi

