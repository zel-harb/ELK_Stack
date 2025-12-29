# User Documentation

This document provides clear instructions for end users and administrators on how to use and manage the Inception infrastructure.

## Table of Contents

1. [Services Overview](#services-overview)
2. [Starting and Stopping the Project](#starting-and-stopping-the-project)
3. [Accessing the Website and Administration Panel](#accessing-the-website-and-administration-panel)
4. [Managing Credentials](#managing-credentials)
5. [Checking Service Status](#checking-service-status)

---

## Services Overview

The Inception infrastructure provides the following services:

### 1. **Nginx Web Server**
- **Purpose**: Serves as a secure reverse proxy and web server
- **Features**:
  - TLSv1.2/TLSv1.3 SSL/TLS encryption
  - Handles HTTPS requests on port 443
  - Routes traffic to the WordPress application
  - Serves static content efficiently

### 2. **WordPress**
- **Purpose**: Content Management System for creating and managing your website
- **Features**:
  - Full WordPress installation with PHP-FPM
  - User-friendly interface for content creation
  - Plugin and theme support
  - Media library management
  - User role management

### 3. **MariaDB Database**
- **Purpose**: Stores all WordPress data (posts, pages, users, settings)
- **Features**:
  - Persistent data storage
  - Automatic backups through Docker volumes
  - Isolated network access (not exposed externally)
  - Reliable MySQL-compatible database engine

---

## Starting and Stopping the Project

### Starting the Infrastructure

To start all services, navigate to the project directory and run:

```bash
make all
```

This command will:
1. Create necessary data directories
2. Build all Docker containers (if not already built)
3. Start all services (Nginx, WordPress, MariaDB)
4. Display a success message when ready

**Alternative**: If you've already built the containers, you can simply start them:

```bash
make up
```

**Expected Output**:
```
✓ Inception is running!
```

The services will start in the following order:
1. MariaDB (database must be ready first)
2. WordPress (connects to the database)
3. Nginx (serves the WordPress application)

### Stopping the Infrastructure

To stop all running services without losing data:

```bash
make down
```

This will:
- Stop all containers gracefully
- Preserve all data in the volumes
- Free up system resources

**Data Safety**: Your WordPress content and database remain intact in the persistent volumes.

---

## Accessing the Website and Administration Panel

### Accessing the Website

Once the infrastructure is running, you can access your WordPress website at:

**URL**: `https://zel-harb.42.fr`

**Note**: 
- The connection uses HTTPS (SSL/TLS encryption)
- You may see a browser warning about the SSL certificate if using a self-signed certificate
- To bypass the warning, click "Advanced" → "Proceed to site" (Chrome/Edge) or "Advanced" → "Accept the Risk" (Firefox)

### Accessing the WordPress Admin Panel

To manage your website content, access the WordPress administration panel:

**URL**: `https://zel-harb.42.fr/wp-admin`

**Login Steps**:
1. Navigate to the admin URL
2. Enter your WordPress username and password
3. Click "Log In"


---

## Managing Credentials

### Location of Credentials

Credentials and sensitive configuration are stored in the following locations:

#### 1. **Environment Variables**
Located in: `srcs/.env` (if present) or defined in `docker-compose.yml`

Typical variables include:
- `MYSQL_ROOT_PASSWORD` - MariaDB root password
- `MYSQL_DATABASE` - WordPress database name
- `MYSQL_USER` - WordPress database username
- `MYSQL_PASSWORD` - WordPress database password
- `WP_ADMIN_USER` - WordPress administrator username
- `WP_ADMIN_PASSWORD` - WordPress administrator password
- `WP_ADMIN_EMAIL` - WordPress administrator email

#### 2. **WordPress Credentials**

**To view/change WordPress user credentials:**

1. **Through WordPress Admin Panel** (recommended):
   - Log in to `https://zel-harb.42.fr/wp-admin`
   - Navigate to `Users` → `All Users`
   - Click on a user to edit their profile
   - Scroll to "Account Management" to change passwords

2. **Through Database** (advanced):
   ```bash
   # Access MariaDB container
   docker exec -it mariadb mysql -u root -p
   
   # Select WordPress database
   USE wordpress;
   
   # View users
   SELECT user_login, user_email FROM wp_users;
   ```

#### 3. **Database Credentials**

To access the database directly:

```bash
# Enter the MariaDB container
docker exec -it mariadb bash

# Connect to MySQL
mysql -u root -p
# Enter the root password when prompted
```

### Security Best Practices

⚠️ **Important Security Notes**:

- **Never commit credentials to Git**: Ensure `.env` files are in `.gitignore`
- **Use strong passwords**: Minimum 12 characters with mixed case, numbers, and symbols
- **Change default passwords**: Always change default passwords after first deployment
- **Limit access**: Only share credentials with authorized personnel
- **Regular updates**: Change passwords periodically

---

## Checking Service Status

### Quick Health Check

To verify all services are running correctly:

```bash
docker ps
```

**Expected Output**:
```
CONTAINER ID   IMAGE       COMMAND                  STATUS         PORTS                   NAMES
abc123...      nginx       "nginx -g 'daemon of…"   Up 5 minutes   0.0.0.0:443->443/tcp    nginx
def456...      wordpress   "docker-entrypoint.s…"   Up 5 minutes   9000/tcp                wordpress
ghi789...      mariadb     "docker-entrypoint.s…"   Up 5 minutes   3306/tcp                mariadb
```

All three containers should show `STATUS` as `Up`.

### Detailed Service Checks

#### 1. **Check Nginx**

Verify Nginx is serving content:

```bash
curl -k https://zel-harb.42.fr
```

You should see HTML content from your WordPress site.

**Check Nginx logs**:
```bash
docker logs nginx
```

#### 2. **Check WordPress**

Verify WordPress is responding:

```bash
docker logs wordpress
```

Look for successful PHP-FPM startup messages and database connection confirmations.

**Test PHP-FPM**:
```bash
docker exec wordpress ps aux | grep php-fpm
```

Should show running PHP-FPM processes.

#### 3. **Check MariaDB**

Verify database is running and accessible:

```bash
docker exec mariadb mysqladmin ping -p
```

Enter the root password when prompted. Should output: `mysqld is alive`

**Check database logs**:
```bash
docker logs mariadb
```

Look for messages indicating successful startup and readiness.

### Network Connectivity Check

Verify containers can communicate:

```bash
# From WordPress container, ping MariaDB
docker exec wordpress ping -c 3 mariadb

# Check if WordPress can connect to database
docker exec wordpress wp db check --allow-root
```

### Volume and Data Persistence Check

Verify data volumes are mounted correctly:

```bash
# Check volume mounts
docker volume ls

# Inspect volume details
docker volume inspect inception_wordpress_data
docker volume inspect inception_mariadb_data

# Check data directories on host
ls -la /home/zel-harb/data/wordpress
ls -la /home/zel-harb/data/mariadb
```

### Troubleshooting Common Issues

#### Issue: Cannot access website

**Solution**:
1. Check if all containers are running: `docker ps`
2. Check Nginx logs: `docker logs nginx`
3. Verify port 443 is not blocked by firewall
4. Ensure domain name resolves correctly in `/etc/hosts`

#### Issue: WordPress shows "Error establishing database connection"

**Solution**:
1. Check MariaDB is running: `docker ps | grep mariadb`
2. Verify database credentials in environment variables
3. Check MariaDB logs: `docker logs mariadb`
4. Test database connection: `docker exec wordpress wp db check --allow-root`

#### Issue: SSL certificate warning

**Solution**:
- This is expected with self-signed certificates
- For production, obtain a certificate from Let's Encrypt or another CA
- For testing, proceed through the browser warning

#### Issue: Containers keep restarting

**Solution**:
1. Check container logs: `docker logs <container_name>`
2. Look for error messages in the logs
3. Verify configuration files are correct
4. Check if required ports are available
5. Ensure sufficient disk space: `df -h`

---

## Support

For additional help:
- Review the main [README.md](README.md) for project overview
- Consult [DEV_DOC.md](DEV_DOC.md) for technical details
- Check Docker and WordPress documentation linked in Resources section
