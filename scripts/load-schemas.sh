#!/bin/bash

# Load database schemas into MySQL
# Run this script after setting up MySQL

echo "=== Loading Database Schemas ==="

# Configuration
MYSQL_HOST="${MYSQL_HOST:-localhost}"
MYSQL_USER="${MYSQL_USER:-appuser}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-AppPassword123!}"

echo "MySQL Host: $MYSQL_HOST"
echo "MySQL User: $MYSQL_USER"
echo ""

# Load User Service schema
echo "Loading User Service schema..."
mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" < schema/user_service_schema.sql
if [ $? -eq 0 ]; then
    echo "✅ User Service schema loaded successfully"
else
    echo "❌ Failed to load User Service schema"
    exit 1
fi

# Load Order Service schema (optional)
echo ""
echo "Loading Order Service schema..."
mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" < schema/order_service_schema.sql
if [ $? -eq 0 ]; then
    echo "✅ Order Service schema loaded successfully"
else
    echo "❌ Failed to load Order Service schema"
    exit 1
fi

# Verify databases
echo ""
echo "Verifying databases..."
mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SHOW DATABASES;"

echo ""
echo "Verifying tables in user_service_db..."
mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" user_service_db -e "SHOW TABLES;"

echo ""
echo "Sample data count:"
mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" user_service_db -e "
SELECT 'Users' AS table_name, COUNT(*) AS record_count FROM users
UNION ALL
SELECT 'User Profiles', COUNT(*) FROM user_profiles
UNION ALL
SELECT 'User Addresses', COUNT(*) FROM user_addresses;
"

echo ""
echo "=== Database Setup Complete ==="

