# Database Repository

Database schemas and setup scripts for the microservices architecture.

## Overview

This repository contains:
- MySQL database schemas for all microservices
- Setup and deployment scripts for GCP
- Connection testing utilities
- Sample data for development

## Schemas

### User Service Database (`user_service_db`)

**Tables:**
- `users` - Main user information
- `user_profiles` - Extended user profile data
- `user_addresses` - User address management

**Features:**
- Email uniqueness constraint
- Status tracking (active/inactive/suspended)
- Automatic timestamps
- Sample data included

### Order Service Database (`order_service_db`)

**Tables:**
- `orders` - Main order records
- `order_items` - Individual items in orders
- `shipping_addresses` - Delivery addresses

**Features:**
- UUID-based order IDs
- Status tracking through order lifecycle
- Relational integrity with foreign keys
- Sample data included

## GCP MySQL VM Setup

### 1. Create MySQL VM

```bash
# Create the VM
gcloud compute instances create mysql-vm \
  --zone=us-central1-a \
  --machine-type=e2-medium \
  --image-family=ubuntu-2004-lts \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=20GB \
  --tags=mysql-server

# Configure firewall for internal access only
gcloud compute firewall-rules create allow-mysql-internal \
  --allow=tcp:3306 \
  --source-ranges=10.128.0.0/20 \
  --target-tags=mysql-server \
  --description="Allow MySQL access from internal VMs"
```

### 2. Install and Configure MySQL

```bash
# SSH into the VM
gcloud compute ssh mysql-vm --zone=us-central1-a

# Clone this repository
git clone <your-database-repo-url>
cd database-repo

# Run setup script
chmod +x scripts/setup-mysql-vm.sh
./scripts/setup-mysql-vm.sh
```

The setup script will:
- Install MySQL Server
- Configure for remote access (internal only)
- Create application user
- Secure the installation

### 3. Load Database Schemas

```bash
# Still on MySQL VM
cd database-repo
chmod +x scripts/load-schemas.sh
./scripts/load-schemas.sh
```

### 4. Get Internal IP

```bash
# On MySQL VM
hostname -I | awk '{print $1}'

# Or from your local machine
gcloud compute instances describe mysql-vm \
  --zone=us-central1-a \
  --format='get(networkInterfaces[0].networkIP)'
```

**Save this internal IP** - you'll need it to configure your microservices.

## Connecting Microservices to MySQL

### Update Microservice Configuration

In each microservice's `.env` file:

```bash
# User Service .env
DB_HOST=<mysql-vm-internal-ip>
DB_USER=appuser
DB_PASSWORD=AppPassword123!
DB_NAME=user_service_db
DB_PORT=3306
```

### Test Connection

From any microservice VM:

```bash
# Install MySQL client if needed
sudo apt-get install mysql-client -y

# Test connection
export MYSQL_HOST=<mysql-vm-internal-ip>
chmod +x scripts/test-connection.sh
./scripts/test-connection.sh
```

## Manual Database Operations

### Connect to MySQL

```bash
# From MySQL VM
mysql -u appuser -p
# Enter password: AppPassword123!

# From microservice VM (with internal IP)
mysql -h <mysql-vm-internal-ip> -u appuser -p
```

### Common Commands

```sql
-- Show all databases
SHOW DATABASES;

-- Use a database
USE user_service_db;

-- Show tables
SHOW TABLES;

-- View users
SELECT * FROM users;

-- View table structure
DESCRIBE users;

-- Check record counts
SELECT 
  'Users' AS table_name, 
  COUNT(*) AS count 
FROM users;
```

## Security Considerations

### ⚠️ Change Default Passwords

The setup scripts use default passwords for convenience. **CHANGE THESE IN PRODUCTION!**

```sql
-- Change root password
ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_secure_password';

-- Change app user password
ALTER USER 'appuser'@'%' IDENTIFIED BY 'new_secure_password';
FLUSH PRIVILEGES;
```

### Firewall Configuration

The firewall rule only allows connections from internal VMs in the same VPC:
- Source range: `10.128.0.0/20` (GCP default internal range)
- Port: 3306
- Target: VMs with `mysql-server` tag

### Best Practices

1. **Never expose MySQL to the internet** (no external IP on MySQL VM)
2. **Use strong passwords** in production
3. **Regular backups** - set up automated backups in GCP
4. **Monitor connections** - check MySQL logs regularly
5. **Least privilege** - create separate users per microservice if needed

## Database Backup and Restore

### Backup

```bash
# Backup all databases
mysqldump -u appuser -p --all-databases > backup_all.sql

# Backup specific database
mysqldump -u appuser -p user_service_db > backup_user_service.sql

# Backup to GCS
mysqldump -u appuser -p --all-databases | gzip | gsutil cp - gs://your-bucket/backup_$(date +%Y%m%d).sql.gz
```

### Restore

```bash
# Restore from backup
mysql -u appuser -p < backup_all.sql

# Restore specific database
mysql -u appuser -p user_service_db < backup_user_service.sql
```

## Troubleshooting

### Connection Issues

1. **Check MySQL is running:**
   ```bash
   sudo systemctl status mysql
   ```

2. **Verify bind address:**
   ```bash
   sudo cat /etc/mysql/mysql.conf.d/mysqld.cnf | grep bind-address
   # Should be: bind-address = 0.0.0.0
   ```

3. **Check firewall rules:**
   ```bash
   gcloud compute firewall-rules list --filter="name:mysql"
   ```

4. **Test from microservice VM:**
   ```bash
   telnet <mysql-vm-internal-ip> 3306
   ```

5. **Check MySQL logs:**
   ```bash
   sudo tail -f /var/log/mysql/error.log
   ```

### Permission Issues

```sql
-- Show user privileges
SHOW GRANTS FOR 'appuser'@'%';

-- Grant additional privileges if needed
GRANT ALL PRIVILEGES ON *.* TO 'appuser'@'%';
FLUSH PRIVILEGES;
```

## Project Structure

```
database-repo/
├── schema/
│   ├── user_service_schema.sql    # User service database
│   └── order_service_schema.sql   # Order service database (optional)
├── scripts/
│   ├── setup-mysql-vm.sh          # Initial MySQL setup
│   ├── load-schemas.sh            # Load all schemas
│   └── test-connection.sh         # Test connectivity
└── README.md
```

## Development Team Notes

- Each microservice can have its own database for true microservice isolation
- Shared MySQL instance is used for simplicity (can be separated later)
- Sample data is automatically loaded for testing
- All scripts are idempotent (safe to run multiple times)
- Internal IPs are private and not routable from internet

## Schema Migrations

For future schema changes, consider using a migration tool:
- **Flyway** - Java-based migration tool
- **Liquibase** - Database-independent migrations
- **Knex.js** - JavaScript migrations (if using Node.js)
- **Alembic** - Python migrations

## Monitoring

Set up monitoring for:
- Connection count
- Query performance
- Disk usage
- Backup success/failure
- Replication lag (if using replication)

Use GCP's Cloud Monitoring or Prometheus + Grafana.

## Next Steps

1. ✅ Set up MySQL VM
2. ✅ Load schemas and sample data
3. ✅ Configure microservices to connect
4. ✅ Test connectivity
5. Set up automated backups
6. Configure monitoring
7. Implement schema migration strategy
8. Set up replication for high availability (optional)

