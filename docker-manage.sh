#!/bin/bash

# Docker Management Script - Template for any project
# Generic script to easily manage Docker Compose projects

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration - Modify these variables for your project
PROJECT_NAME="my-project"                    # Replace with your project name
DATABASE_NAME="my_database"                  # Replace with your database name
DATABASE_USER="postgres"                     # Replace with your database user
API_PORT="8000"                             # Replace with your API port
DB_PORT="5432"                              # Replace with your database port
COMPOSE_FILE="docker-compose.yml"           # Replace with your compose file name

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Docker Manager - $PROJECT_NAME${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Function to start services
start_services() {
    print_info "🚀 Starting Docker services..."
    docker-compose -f $COMPOSE_FILE up -d --force-recreate
    print_info "✅ Services started successfully!"
    print_info "🌐 API available at: http://localhost:$API_PORT"
    print_info "🗄️ Database available at: localhost:$DB_PORT"
}

# Function to stop services
stop_services() {
    print_info "🛑 Stopping Docker services..."
    docker-compose -f $COMPOSE_FILE down
    print_info "✅ Services stopped successfully!"
}

# Function to rebuild and restart
rebuild_services() {
    print_info "🔨 Rebuilding images and restarting services..."
    docker-compose -f $COMPOSE_FILE down
    docker-compose -f $COMPOSE_FILE build --no-cache
    docker-compose -f $COMPOSE_FILE up -d
    print_info "✅ Services rebuilt and restarted successfully!"
}

# Function to show logs
show_logs() {
    if [ -z "$1" ]; then
        print_info "📋 Showing all service logs (Ctrl+C to exit)..."
        docker-compose -f $COMPOSE_FILE logs -f
    else
        print_info "📋 Showing logs for service: $1 (Ctrl+C to exit)..."
        docker-compose -f $COMPOSE_FILE logs -f "$1"
    fi
}

# Function to enter a container
enter_container() {
    if [ -z "$1" ]; then
        print_error "Please specify a service name"
        print_info "Available services: $(docker-compose -f $COMPOSE_FILE config --services | tr '\n' ' ')"
        exit 1
    fi
    print_info "🐚 Entering container for service: $1"
    docker-compose -f $COMPOSE_FILE exec "$1" bash
}

# Function to clean up
clean() {
    print_warning "🧹 Cleaning up containers, images, and volumes..."
    read -p "Are you sure? This will remove all data! (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker-compose -f $COMPOSE_FILE down -v
        docker-compose -f $COMPOSE_FILE rm -f
        docker system prune -f
        print_info "✅ Cleanup completed!"
    else
        print_info "Cleanup cancelled."
    fi
}

# Function to connect to database
connect_db() {
    echo "-------------------------------"
    print_info "🗄️ Connecting to database: $DATABASE_NAME"
    echo ""
    print_info "💡 Useful commands:"
    print_info "   \\l          - List databases"
    print_info "   \\dt         - List tables"
    print_info "   \\d users    - Describe table 'users'"
    print_info "   SELECT COUNT(*) FROM table_name; - Count records"
    print_info "   \\q          - Quit"
    echo "-------------------------------"
    docker-compose -f $COMPOSE_FILE exec postgres psql -U $DATABASE_USER -d $DATABASE_NAME
}

# Function to run SQL query
run_sql() {
    if [ -z "$1" ]; then
        print_error "Please specify an SQL query"
        print_info "Example: $0 sql 'SELECT * FROM users LIMIT 5;'"
        exit 1
    fi
    print_info "🔍 Executing SQL query..."
    docker-compose -f $COMPOSE_FILE exec postgres psql -U $DATABASE_USER -d $DATABASE_NAME -c "$1"
}

# Function to check service status
check_services() {
    print_info "🔍 Checking service status..."
    docker-compose -f $COMPOSE_FILE ps
}

# Function to backup database
backup_db() {
    BACKUP_FILE="backup_${DATABASE_NAME}_$(date +%Y%m%d_%H%M%S).sql"
    print_info "💾 Creating database backup: $BACKUP_FILE"
    docker-compose -f $COMPOSE_FILE exec postgres pg_dump -U $DATABASE_USER $DATABASE_NAME > $BACKUP_FILE
    print_info "✅ Backup created successfully!"
}

# Function to restore database
restore_db() {
    if [ -z "$1" ]; then
        print_error "Please specify backup file path"
        print_info "Example: $0 restore backup_file.sql"
        exit 1
    fi
    if [ ! -f "$1" ]; then
        print_error "Backup file not found: $1"
        exit 1
    fi
    print_warning "⚠️  This will overwrite the current database!"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "🔄 Restoring database from: $1"
        docker-compose -f $COMPOSE_FILE exec -T postgres psql -U $DATABASE_USER $DATABASE_NAME < "$1"
        print_info "✅ Database restored successfully!"
    else
        print_info "Restore cancelled."
    fi
}

# Function to update services
update_services() {
    print_info "⬆️  Updating services..."
    docker-compose -f $COMPOSE_FILE pull
    docker-compose -f $COMPOSE_FILE up -d
    print_info "✅ Services updated successfully!"
}

# Function to show service configuration
show_config() {
    print_info "⚙️  Current configuration:"
    echo "Project Name: $PROJECT_NAME"
    echo "Database: $DATABASE_NAME"
    echo "Database User: $DATABASE_USER"
    echo "API Port: $API_PORT"
    echo "Database Port: $DB_PORT"
    echo "Compose File: $COMPOSE_FILE"
}

# Main menu
case "$1" in
    start)
        print_header
        start_services
        ;;
    stop)
        print_header
        stop_services
        ;;
    restart)
        print_header
        stop_services
        start_services
        ;;
    rebuild)
        print_header
        rebuild_services
        ;;
    logs)
        print_header
        show_logs "$2"
        ;;
    shell)
        print_header
        enter_container "$2"
        ;;
    db)
        print_header
        connect_db
        ;;
    sql)
        print_header
        run_sql "$2"
        ;;
    backup)
        print_header
        backup_db
        ;;
    restore)
        print_header
        restore_db "$2"
        ;;
    clean)
        print_header
        clean
        ;;
    check)
        print_header
        check_services
        ;;
    update)
        print_header
        update_services
        ;;
    config)
        print_header
        show_config
        ;;
    *)
        print_header
        echo ""
        echo "Usage: $0 {command} [options]"
        echo ""
        echo "📋 Available commands:"
        echo "  start     - Start all services"
        echo "  stop      - Stop all services"
        echo "  restart   - Restart all services"
        echo "  rebuild   - Rebuild and restart all services"
        echo "  logs      - Show logs (optional: specify service name)"
        echo "  shell     - Enter container shell (specify service name)"
        echo "  db        - Connect to database directly"
        echo "  sql       - Execute SQL query"
        echo "  backup    - Create database backup"
        echo "  restore   - Restore database from backup"
        echo "  update    - Update services to latest images"
        echo "  clean     - Clean up containers, images, and volumes"
        echo "  check     - Check service status"
        echo "  config    - Show current configuration"
        echo ""
        echo "📝 Examples:"
        echo "  $0 start"
        echo "  $0 logs api"
        echo "  $0 shell web"
        echo "  $0 db"
        echo "  $0 sql 'SELECT COUNT(*) FROM users;'"
        echo "  $0 backup"
        echo "  $0 restore backup_file.sql"
        echo ""
        echo "⚙️  Configuration :"
        echo "  Project: $PROJECT_NAME"
        echo "  Database: $DATABASE_NAME"
        echo "  API Port: $API_PORT"
        echo "  DB Port: $DB_PORT"
        exit 1
        ;;
esac