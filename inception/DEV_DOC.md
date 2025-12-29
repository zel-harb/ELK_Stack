# Developer Documentation

This document provides technical information for developers working on the Inception project, including environment setup, build processes, and container management.

## Table of Contents

1. [Environment Setup](#environment-setup)
2. [Project Structure](#project-structure)
3. [Building and Launching](#building-and-launching)
4. [Container Management](#container-management)
5. [Volume Management](#volume-management)
6. [Data Persistence](#data-persistence)
7. [Networking](#networking)
8. [Development Workflow](#development-workflow)
9. [Debugging and Troubleshooting](#debugging-and-troubleshooting)

---

## Environment Setup

### Prerequisites

Before setting up the development environment, ensure the following are installed:

1. **Docker Engine** (version 20.10 or higher)
   ```bash
   # Check Docker version
   docker --version
   
   # Install Docker on Debian/Ubuntu
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   
   # Add user to docker group (avoid sudo)
   sudo usermod -aG docker $USER
   newgrp docker
   ```

2. **Docker Compose** (version 1.29 or higher, or Docker Compose V2)
   ```bash
   # Check Docker Compose version
   docker compose version
   
   # Docker Compose V2 is included with Docker Desktop
   # For Linux, it's installed with Docker Engine
   ```

3. **Make** (build automation tool)
   ```bash
   # Check Make version
   make --version
   
   # Install on Debian/Ubuntu
   sudo apt-get install make
   ```

4. **Git** (version control)
   ```bash
   # Check Git version
   git --version
   
   # Install on Debian/Ubuntu
   sudo apt-get install git
   ```

### Initial Setup from Scratch

#### 1. Clone the Repository

```bash
git clone <repository-url> inception
cd inception
```

#### 2. Configure Environment Variables

Create or modify environment variables for the services. These can be set in:
- `srcs/.env` file (recommended for local development)
- Directly in `srcs/docker-compose.yml` (for testing)

**Example `.env` file**:
```bash
# Database Configuration
MYSQL_ROOT_PASSWORD=secure_root_password
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD=secure_wp_password

# WordPress Configuration
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=secure_admin_password
WP_ADMIN_EMAIL=admin@example.com
WP_TITLE="My Inception Site"
WP_URL=https://zel-harb.42.fr

# Domain Configuration
DOMAIN_NAME=zel-harb.42.fr
```

**Security Note**: Never commit `.env` files to Git. Ensure `.gitignore` includes:
```
.env
*.env
```

#### 3. Configure Hosts File (for local development)

Add the domain to your `/etc/hosts` file:

```bash
sudo nano /etc/hosts
```

Add this line:
```
127.0.0.1   zel-harb.42.fr
```

#### 4. Generate SSL Certificates (if needed)

If SSL certificates are not included, generate self-signed certificates:

```bash
# Navigate to nginx configuration directory
cd srcs/requirements/nginx/tools

# Generate self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx.key -out nginx.crt \
  -subj "/C=XX/ST=State/L=City/O=42/OU=Student/CN=zel-harb.42.fr"
```

#### 5. Set Up Data Directories

The Makefile automatically creates data directories, but you can do it manually:

```bash
mkdir -p /home/zel-harb/data/wordpress
mkdir -p /home/zel-harb/data/mariadb
```

Set appropriate permissions:
```bash
sudo chown -R $USER:$USER /home/zel-harb/data
chmod -R 755 /home/zel-harb/data
```

---

## Project Structure

```
inception/
├── Makefile                          # Build automation
├── README.md                         # Project overview
├── USER_DOC.md                       # User documentation
├── DEV_DOC.md                        # Developer documentation (this file)
├── remove.sh                         # Cleanup script
└── srcs/
    ├── docker-compose.yml            # Multi-container orchestration
    ├── .env                          # Environment variables (not in Git)
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile            # MariaDB container definition
        │   ├── conf/
        │   │   └── 50-server.cnf     # MariaDB configuration
        │   └── tools/
        │       └── script.sh         # Database initialization script
        ├── nginx/
        │   ├── Dockerfile            # Nginx container definition
        │   ├── conf/
        │   │   └── file.conf         # Nginx server configuration
        │   └── tools/
        │       └── script.sh         # Nginx setup script
        └── wordpress/
            ├── Dockerfile            # WordPress container definition
            └── tools/
                └── script.sh         # WordPress installation script
```

### Key Files Explained

- **`Makefile`**: Defines build targets (`all`, `build`, `up`, `down`, `clean`, `fclean`, `re`)
- **`docker-compose.yml`**: Orchestrates the three services, defines networks and volumes
- **`Dockerfile`**: Each service has its own Dockerfile built from Alpine/Debian base images
- **Configuration files**: Service-specific configs (Nginx server blocks, MariaDB settings)
- **Scripts**: Initialization and setup scripts run during container startup

---

## Building and Launching

### Using the Makefile

The Makefile provides convenient targets for common operations:

#### Build All Images

```bash
make build
```

**What it does**:
1. Creates data directories if they don't exist
2. Runs `docker compose -f srcs/docker-compose.yml build`
3. Builds custom images for nginx, wordpress, and mariadb from their Dockerfiles

**No cache build** (force rebuild):
```bash
docker compose -f srcs/docker-compose.yml build --no-cache
```

#### Start Services

```bash
make up
```

**What it does**:
1. Creates data directories if they don't exist
2. Starts all containers defined in docker-compose.yml
3. Containers run in detached mode (background)

**Foreground mode** (see logs in real-time):
```bash
docker compose -f srcs/docker-compose.yml up
```

#### Build and Start (Complete Setup)

```bash
make all
```

**What it does**:
1. Runs `make build`
2. Runs `make up`
3. Displays success message

#### Stop Services

```bash
make down
```

**What it does**:
- Stops all running containers
- Removes containers
- Preserves volumes and data

#### Clean Up

```bash
# Remove containers and volumes
make clean

# Complete cleanup (images, containers, volumes, data directories)
make fclean

# Rebuild from scratch
make re
```

### Using Docker Compose Directly

For more control, use Docker Compose commands directly:

```bash
# Build specific service
docker compose -f srcs/docker-compose.yml build nginx

# Start specific service
docker compose -f srcs/docker-compose.yml up -d mariadb

# View logs
docker compose -f srcs/docker-compose.yml logs -f

# Stop services
docker compose -f srcs/docker-compose.yml stop

# Remove containers
docker compose -f srcs/docker-compose.yml down

# Remove containers and volumes
docker compose -f srcs/docker-compose.yml down -v
```

---

## Container Management

### Listing Containers

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# List containers with specific format
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### Inspecting Containers

```bash
# View container details
docker inspect nginx
docker inspect wordpress
docker inspect mariadb

# View container resource usage
docker stats

# View container processes
docker top nginx
```

### Accessing Container Shells

```bash
# Access Nginx container
docker exec -it nginx sh

# Access WordPress container
docker exec -it wordpress bash

# Access MariaDB container
docker exec -it mariadb bash
```

### Viewing Logs

```bash
# View logs from all services
docker compose -f srcs/docker-compose.yml logs

# Follow logs in real-time
docker compose -f srcs/docker-compose.yml logs -f

# View logs for specific service
docker logs nginx
docker logs wordpress
docker logs mariadb


```

### Restarting Containers

```bash
# Restart all services
docker compose -f srcs/docker-compose.yml restart

# Restart specific service
docker restart nginx
docker restart wordpress
docker restart mariadb
```

### Removing Containers

```bash
# Stop and remove specific container
docker stop nginx
docker rm nginx

# Force remove running container
docker rm -f nginx

# Remove all stopped containers
docker container prune
```

---

## Volume Management

### Docker Volumes

This project uses Docker volumes for persistent data storage.

#### Listing Volumes

```bash
# List all volumes
docker volume ls

# List volumes with filter
docker volume ls --filter name=inception
```

#### Inspecting Volumes

```bash
# View volume details
docker volume inspect inception_wordpress_data
docker volume inspect inception_mariadb_data

# View volume mount point
docker volume inspect inception_wordpress_data --format '{{ .Mountpoint }}'
```

#### Creating Volumes Manually

```bash
# Create a volume
docker volume create inception_wordpress_data
docker volume create inception_mariadb_data
```

#### Backing Up Volumes

```bash
# Backup WordPress data
docker run --rm \
  -v inception_wordpress_data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/wordpress_backup.tar.gz -C /data .

# Backup MariaDB data
docker run --rm \
  -v inception_mariadb_data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/mariadb_backup.tar.gz -C /data .
```

#### Restoring Volumes

```bash
# Restore WordPress data
docker run --rm \
  -v inception_wordpress_data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/wordpress_backup.tar.gz -C /data

# Restore MariaDB data
docker run --rm \
  -v inception_mariadb_data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/mariadb_backup.tar.gz -C /data
```

#### Removing Volumes

```bash
# Remove specific volume (must stop containers first)
docker volume rm inception_wordpress_data

# Remove all unused volumes
docker volume prune

# Remove volumes when removing containers
docker compose -f srcs/docker-compose.yml down -v
```

### Bind Mounts (Alternative Approach)

This project uses bind mounts to map host directories to container paths:

**WordPress Data**: `/home/zel-harb/data/wordpress`  
**MariaDB Data**: `/home/zel-harb/data/mariadb`

These are defined in `docker-compose.yml`:
```yaml
volumes:
  - /home/zel-harb/data/wordpress:/var/www/html
  - /home/zel-harb/data/mariadb:/var/lib/mysql
```

---

## Data Persistence

### Where Data is Stored

#### 1. WordPress Files
**Location**: `/home/zel-harb/data/wordpress` (host) → `/var/www/html` (container)

**Contents**:
- WordPress core files
- Themes (`wp-content/themes/`)
- Plugins (`wp-content/plugins/`)
- Uploads (`wp-content/uploads/`)
- Configuration (`wp-config.php`)

**Viewing WordPress data**:
```bash
ls -la /home/zel-harb/data/wordpress
```

#### 2. MariaDB Database
**Location**: `/home/zel-harb/data/mariadb` (host) → `/var/lib/mysql` (container)

**Contents**:
- Database files
- Table data
- Binary logs
- System databases

**Viewing database data**:
```bash
ls -la /home/zel-harb/data/mariadb
```

### Persistence Verification

#### Test Data Persistence

1. **Create content in WordPress**:
   - Log in to WordPress admin
   - Create a new post or page
   - Upload media files

2. **Stop and remove containers**:
   ```bash
   make down
   ```

3. **Restart containers**:
   ```bash
   make up
   ```

4. **Verify data persists**:
   - Log in to WordPress admin
   - Confirm posts, pages, and media are still present

#### Database Persistence Test

```bash
# Access database and create test data
docker exec -it mariadb mysql -u root -p
CREATE DATABASE test_db;
USE test_db;
CREATE TABLE test_table (id INT, name VARCHAR(50));
INSERT INTO test_table VALUES (1, 'test');
EXIT;

# Restart container
docker restart mariadb

# Verify data persists
docker exec -it mariadb mysql -u root -p -e "SELECT * FROM test_db.test_table;"
```

### Data Backup Strategy

#### WordPress Backup

```bash
# Backup WordPress files
tar -czf wordpress_backup_$(date +%Y%m%d).tar.gz /home/zel-harb/data/wordpress

# Backup WordPress database
docker exec mariadb mysqldump -u root -p wordpress > wordpress_db_backup_$(date +%Y%m%d).sql
```

#### Complete System Backup

```bash
# Create backup directory
mkdir -p ~/inception_backups

# Backup all data
tar -czf ~/inception_backups/inception_full_backup_$(date +%Y%m%d).tar.gz \
  /home/zel-harb/data/wordpress \
  /home/zel-harb/data/mariadb

# Backup database separately
docker exec mariadb mysqldump -u root -p --all-databases > \
  ~/inception_backups/all_databases_$(date +%Y%m%d).sql
```

---

## Networking

### Docker Network Architecture

The project uses a custom Docker bridge network for service communication.

#### Network Configuration

In `docker-compose.yml`:
```yaml
networks:
  inception:
    driver: bridge
```

#### Inspecting the Network

```bash
# List networks
docker network ls

# Inspect the inception network
docker network inspect inception

# View connected containers
docker network inspect inception --format '{{range .Containers}}{{.Name}} {{end}}'
```

#### Service Discovery

Containers can communicate using service names as hostnames:

- **WordPress → MariaDB**: `mysql://mariadb:3306`
- **Nginx → WordPress**: `fastcgi_pass wordpress:9000`

#### Testing Network Connectivity

```bash
# From WordPress container, ping MariaDB
docker exec wordpress ping -c 3 mariadb

# From WordPress container, test MariaDB connection
docker exec wordpress nc -zv mariadb 3306

# From Nginx container, test WordPress
docker exec nginx nc -zv wordpress 9000
```

#### Port Mapping

**Nginx**:
- Host: `443` → Container: `443` (HTTPS)

**WordPress**:
- Internal only: `9000` (PHP-FPM, not exposed to host)

**MariaDB**:
- Internal only: `3306` (MySQL, not exposed to host)

---

## Development Workflow

### Making Changes

#### 1. Modifying Dockerfiles

After editing a Dockerfile:

```bash
# Rebuild specific service
docker compose -f srcs/docker-compose.yml build --no-cache nginx

# Restart the service
docker compose -f srcs/docker-compose.yml up -d nginx
```

#### 2. Modifying Configuration Files

After editing config files (nginx.conf, MariaDB config):

```bash
# Copy new config to container (if needed)
docker cp srcs/requirements/nginx/conf/file.conf nginx:/etc/nginx/nginx.conf

# Reload configuration
docker exec nginx nginx -s reload

# Or restart the container
docker restart nginx
```

#### 3. Modifying Scripts

After editing initialization scripts:

```bash
# Rebuild the service
docker compose -f srcs/docker-compose.yml build --no-cache wordpress

# Recreate container
docker compose -f srcs/docker-compose.yml up -d --force-recreate wordpress
```

### Testing Changes

```bash
# View real-time logs
docker compose -f srcs/docker-compose.yml logs -f

# Test specific functionality
curl -k https://zel-harb.42.fr

# Check container health
docker ps
docker inspect nginx --format='{{.State.Health.Status}}'
```

---

## Debugging and Troubleshooting

### Common Issues and Solutions

#### Issue: Build Fails

**Diagnosis**:
```bash
# Build with verbose output
docker compose -f srcs/docker-compose.yml build --no-cache --progress=plain
```

**Solutions**:
- Check Dockerfile syntax
- Verify base image is accessible
- Check internet connectivity for package downloads
- Review build logs for specific errors

#### Issue: Container Exits Immediately

**Diagnosis**:
```bash
# View exit code
docker inspect wordpress --format='{{.State.ExitCode}}'

# View logs
docker logs wordpress
```

**Solutions**:
- Ensure entrypoint script has execute permissions
- Check script for errors (`set -e` will exit on first error)
- Verify required files and directories exist
- Test script locally before containerizing

#### Issue: Database Connection Failed

**Diagnosis**:
```bash
# Check if MariaDB is ready
docker exec mariadb mysqladmin ping -p

# Test connection from WordPress
docker exec wordpress wp db check --allow-root

# Check network connectivity
docker exec wordpress ping mariadb
```

**Solutions**:
- Verify MariaDB is running: `docker ps | grep mariadb`
- Check database credentials match in both containers
- Ensure MariaDB has finished initializing (check logs)
- Verify WordPress has correct `DB_HOST` value (`mariadb`)

#### Issue: Permission Denied on Volumes

**Diagnosis**:
```bash
# Check volume permissions
ls -la /home/zel-harb/data/wordpress
ls -la /home/zel-harb/data/mariadb

# Check container user
docker exec wordpress id
```

**Solutions**:
```bash
# Fix permissions
sudo chown -R www-data:www-data /home/zel-harb/data/wordpress
sudo chown -R mysql:mysql /home/zel-harb/data/mariadb

# Or match host user
sudo chown -R $USER:$USER /home/zel-harb/data
```

### Debugging Tools

#### Container Shell Access

```bash
# Access with bash
docker exec -it wordpress bash

# Access with sh (Alpine)
docker exec -it nginx sh

# Run as root user
docker exec -it -u root wordpress bash
```

#### Network Debugging

```bash
# Install debugging tools in container
docker exec -it wordpress apt-get update && apt-get install -y iputils-ping dnsutils curl

# Test DNS resolution
docker exec wordpress nslookup mariadb

# Test port connectivity
docker exec wordpress telnet mariadb 3306
```

#### Log Analysis

```bash
# Search logs for errors
docker logs wordpress 2>&1 | grep -i error

# Export logs to file
docker logs wordpress > wordpress_debug.log 2>&1

# Monitor logs in real-time
docker logs -f --tail 50 nginx
```

---

## Additional Developer Resources

### Useful Commands

```bash
# Remove all stopped containers
docker container prune

# Remove all unused images
docker image prune -a

# Remove all unused volumes
docker volume prune

# Complete system cleanup
docker system prune -a --volumes

# View Docker disk usage
docker system df

# Monitor resource usage
docker stats --no-stream
```

### Environment Variables Reference

Check `docker-compose.yml` and service scripts for all available environment variables.

### Code Style and Best Practices

- Follow Docker best practices for Dockerfile creation
- Use `.dockerignore` to exclude unnecessary files
- Minimize layer count in Dockerfiles
- Use specific version tags for base images
- Document all custom scripts
- Use healthchecks in docker-compose.yml
- Never hardcode credentials

---

## Support

For additional technical details:
- Review the main [README.md](README.md) for project overview
- Consult [USER_DOC.md](USER_DOC.md) for user-facing operations
- Check the Resources section in README.md for external documentation
