# Docker Manager

A simple bash script to manage Docker Compose projects with common operations.

## Features

- Start/stop/restart services
- View logs and enter containers
- Database operations (connect, backup, restore)
- Clean up containers and images
- Update services to latest versions
- Show service status and configuration

## Usage

Make the script executable:
```bash
chmod +x docker-manage.sh
```

### Configuration

Edit the variables at the top of `docker-manage.sh`:
```bash
PROJECT_NAME="my-project"
DATABASE_NAME="my_database"
DATABASE_USER="postgres"
API_PORT="8000"
DB_PORT="5432"
COMPOSE_FILE="docker-compose.yml"
```

### Commands

```bash
./docker-manage.sh start          # Start all services
./docker-manage.sh stop           # Stop all services
./docker-manage.sh restart        # Restart all services
./docker-manage.sh rebuild        # Rebuild and restart
./docker-manage.sh logs           # Show all logs
./docker-manage.sh logs api       # Show specific service logs
./docker-manage.sh shell web      # Enter container shell
./docker-manage.sh db             # Connect to database
./docker-manage.sh backup         # Create database backup
./docker-manage.sh restore file   # Restore from backup
./docker-manage.sh clean          # Clean up everything
./docker-manage.sh check          # Check service status
./docker-manage.sh config         # Show configuration
```

## Requirements

- Docker
- Docker Compose
- Bash

## License

MIT License