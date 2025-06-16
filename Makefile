# Taskey Makefile
# Common development tasks

.PHONY: help dev build clean test fmt vet deps run kill

# Default target
.DEFAULT_GOAL := help

# Configuration
BINARY_NAME=taskey
BUILD_DIR=bin
MAIN_PATH=./cmd/server/main.go
DEFAULT_PORT=6000

## help: Show this help message
help:
	@echo "Taskey Development Commands"
	@echo "=========================="
	@sed -n 's/^##//p' $(MAKEFILE_LIST) | column -t -s ':' | sed -e 's/^/ /'

## dev: Start development server (kills existing, builds, runs)
dev:
	@./scripts/dev.sh $(DEFAULT_PORT)

## build: Build the application binary
build:
	@echo "🔨 Building $(BINARY_NAME)..."
	@mkdir -p $(BUILD_DIR)
	@go build -o $(BUILD_DIR)/$(BINARY_NAME) $(MAIN_PATH)
	@echo "✅ Build complete: $(BUILD_DIR)/$(BINARY_NAME)"

## run: Run the application (without rebuild)
run:
	@echo "🚀 Running $(BINARY_NAME)..."
	@./$(BUILD_DIR)/$(BINARY_NAME)

## clean: Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@go clean
	@echo "✅ Clean complete"

## test: Run all tests
test:
	@echo "🧪 Running tests..."
	@go test -v ./...

## fmt: Format Go code
fmt:
	@echo "🎨 Formatting code..."
	@go fmt ./...
	@echo "✅ Code formatted"

## vet: Run Go vet (static analysis)
vet:
	@echo "🔍 Running go vet..."
	@go vet ./...
	@echo "✅ Vet complete"

## deps: Download and tidy dependencies
deps:
	@echo "📦 Managing dependencies..."
	@go mod download
	@go mod tidy
	@echo "✅ Dependencies updated"

## kill: Kill any process running on default port
kill:
	@echo "💀 Killing processes on port $(DEFAULT_PORT)..."
	@lsof -ti:$(DEFAULT_PORT) | xargs kill -9 2>/dev/null || echo "No processes found on port $(DEFAULT_PORT)"

## check: Run all checks (fmt, vet, test)
check: fmt vet test
	@echo "✅ All checks passed"

## port: Show what's using the default port
port:
	@echo "🔍 Checking port $(DEFAULT_PORT)..."
	@lsof -i :$(DEFAULT_PORT) || echo "Port $(DEFAULT_PORT) is available"