*This project has been created as part of the 42 curriculum by zel-harb.*

# Description

This project consists of setting up a small, personal infrastructure using **Docker** and **Docker Compose**. The goal is to learn how to create and orchestrate multiple containers, each running a different service, while ensuring isolation, security, and persistence of data.

## Infrastructure Components

The infrastructure includes the following services:

* **Nginx** - A web server serving as a secure reverse proxy with TLSv1.2 or TLSv1.3 SSL configuration
* **WordPress** - A CMS running with PHP-FPM in a dedicated container (without nginx)
* **MariaDB** - The database engine for WordPress

## Docker Architecture

This project leverages Docker's containerization technology to create an isolated, reproducible environment. Each service runs in its own container, built from custom Dockerfiles (no pre-built images from DockerHub except for Alpine or Debian base images).

### Why Docker?

**Virtual Machines vs Docker:**
- **Virtual Machines** run a full operating system with its own kernel, requiring significant resources (CPU, RAM, storage). Each VM includes a complete OS stack, making them slower to start and more resource-intensive.
- **Docker Containers** share the host's kernel and isolate only the application and its dependencies. They are lightweight, start in seconds, and use fewer resources. For this project, Docker provides faster deployment, easier version control through Dockerfiles, and better resource efficiency.

**Secrets vs Environment Variables:**
- **Environment Variables** are simple key-value pairs visible in container configurations and process lists. They're suitable for non-sensitive configuration data.
- **Secrets** (Docker secrets) are encrypted during transit and at rest, stored securely, and only made available to authorized containers. For production environments, secrets should be used for passwords, API keys, and certificates. In this project, we use environment variables for simplicity, but in production, sensitive data like database passwords should use Docker secrets.

**Docker Network vs Host Network:**
- **Host Network** removes network isolation, making the container use the host's network directly. This offers better performance but sacrifices isolation and portability.
- **Docker Network** creates an isolated network where containers can communicate using service names as hostnames. This project uses a custom Docker bridge network, providing isolation, security, and easy service discovery (e.g., WordPress can connect to MariaDB using the service name).

**Docker Volumes vs Bind Mounts:**
- **Bind Mounts** map a host directory to a container path. They're simple but create tight coupling with the host filesystem structure.
- **Docker Volumes** are managed by Docker, stored in Docker's storage area, and can be easily backed up, migrated, or shared between containers. This project uses volumes for persistent storage of WordPress files and MariaDB data, ensuring data persists across container restarts and can be managed independently of the host filesystem.

# Instructions

## Prerequisites

Before running this project, ensure you have the following installed on your system:

- **Docker**: [Install Docker](https://docs.docker.com/get-docker/)
- **Docker Compose**: [Install Docker Compose](https://docs.docker.com/compose/install/)
- **Make**: Available on most Unix-like systems (Linux, macOS)

## Installation & Setup

1. **Clone or navigate to the project directory:**
   ```bash
   cd inception
   ```

2. **Verify the project structure:**
   Ensure the `srcs/docker-compose.yml` file and all service Dockerfiles are present in the `srcs/requirements/` directory.

## Compilation & Building

Build all Docker images for the services:

```bash
make build
```

This command will:
- Create necessary data directories (`/home/zel-harb/data/wordpress` and `/home/zel-harb/data/mariadb`)
- Build Docker images for Nginx, WordPress, and MariaDB as defined in the `docker-compose.yml`

## Execution

### Start the Infrastructure

Run the complete infrastructure:

```bash
make all
```

This will:
1. Create required data directories
2. Build all Docker images
3. Start all containers in the background
4. Display a success message

Alternatively, to build and start separately:
```bash
make build
make up
```

### Stop the Infrastructure

Stop all running containers without removing data:

```bash
make down
```

### Clean Up

Remove containers and volumes (data will be lost):

```bash
make clean
```

### Full Reset

Completely remove all containers, images, and data directories:

```bash
make fclean
```

### Rebuild Everything

Clean and rebuild from scratch:

```bash
make re
```

## Accessing the Services

Once the infrastructure is running:

- **WordPress**: https://zel-harb.42.fr (Nginx reverse proxy with SSL)
- **MariaDB**: Available internally within the Docker network on port 3306
- **PHP-FPM**: Runs within the WordPress container

## Data Persistence

All persistent data is stored in:
- **WordPress files**: `/home/zel-harb/data/wordpress`
- **Database files**: `/home/zel-harb/data/mariadb`

These directories are created automatically and mounted as Docker volumes for data persistence across container restarts.

# Resources

## Documentation & References

- [Docker Official Documentation](https://docs.docker.com/) - Comprehensive guide to Docker concepts, CLI, and best practices
- [Docker Compose Documentation](https://docs.docker.com/compose/) - Guide to defining and running multi-container applications
- [Nginx Documentation](https://nginx.org/en/docs/) - Official Nginx web server documentation
- [WordPress Docker Image](https://hub.docker.com/_/wordpress) - Reference for WordPress container setup
- [MariaDB Documentation](https://mariadb.org/documentation/) - Database configuration and management
- [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/) - Guidelines for writing efficient Dockerfiles
- [Docker Networking](https://docs.docker.com/network/) - Understanding Docker network drivers and configurations
- [Docker Volumes](https://docs.docker.com/storage/volumes/) - Persistent data storage in Docker


## Tutorials & Articles

- [Docker Training Course for Absolute Beginners](https://learn.kodekloud.com/user/courses/docker-training-course-for-the-absolute-beginner) - KodeKloud comprehensive Docker training

- [Docker for Beginners](https://docker-curriculum.com/) - Comprehensive Docker tutorial
- [Setting up WordPress with Docker](https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-docker-compose) - DigitalOcean guide



## AI Usage

AI tools were used in this project for the following tasks:

- **Configuration Review**: AI helped review and validate Docker Compose configurations and Dockerfile best practices
- **Troubleshooting**: AI provided guidance on debugging container networking issues and volume mount permissions
- **Best Practices**: AI suggested security improvements for SSL configuration and container isolation
