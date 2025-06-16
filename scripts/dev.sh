#!/bin/bash

# Taskey Development Server Script
# Usage: ./scripts/dev.sh [port]

set -e  # Exit on any error

# Configuration
DEFAULT_PORT=6000
PORT=${1:-$DEFAULT_PORT}
BINARY_NAME="taskey"
BUILD_PATH="./bin/${BINARY_NAME}"
MAIN_PATH="./cmd/server/main.go"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to kill process on port
kill_port() {
    local port=$1
    print_status "Checking for processes on port $port..."
    
    if command -v lsof >/dev/null 2>&1; then
        local pids=$(lsof -ti:$port 2>/dev/null || true)
        if [ -n "$pids" ]; then
            print_warning "Found processes on port $port: $pids"
            echo "$pids" | xargs kill -9 2>/dev/null || true
            sleep 1
            print_success "Killed processes on port $port"
        else
            print_status "Port $port is available"
        fi
    else
        print_warning "lsof not available, cannot check port usage"
    fi
}

# Function to build the application
build_app() {
    print_status "Building application..."
    
    # Create bin directory if it doesn't exist
    mkdir -p bin
    
    # Build the application
    if go build -o "$BUILD_PATH" "$MAIN_PATH"; then
        print_success "Build completed: $BUILD_PATH"
    else
        print_error "Build failed"
        exit 1
    fi
}

# Function to start the server
start_server() {
    print_status "Starting server on port $PORT..."
    
    # Set environment variables
    export PORT=$PORT
    
    # Start the server
    if [ -f "$BUILD_PATH" ]; then
        print_success "Starting Taskey server..."
        exec "$BUILD_PATH"
    else
        print_error "Binary not found at $BUILD_PATH"
        exit 1
    fi
}

# Main execution
main() {
    echo "🚀 Taskey Development Server"
    echo "=========================="
    
    # Kill any existing processes on the port
    kill_port "$PORT"
    
    # Build the application
    build_app
    
    # Start the server
    start_server
}

# Handle Ctrl+C gracefully
trap 'print_warning "Shutting down server..."; kill_port "$PORT"; exit 0' INT

# Run main function
main "$@"