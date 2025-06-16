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

## run-simple: Run simple version (no graceful shutdown) 
run-simple:
	@echo "🚀 Running simple server..."
	@go run cmd/server/simple_main.go

## test-quick: Quick test with simple server
test-quick:
	@echo "🧪 Quick test cycle..."
	@go run cmd/server/simple_main.go & \
	SERVER_PID=$$!; \
	sleep 2; \
	curl -s http://localhost:6000/health | grep "healthy" && echo "✅ Health check passed" || echo "❌ Health check failed"; \
	kill $$SERVER_PID 2>/dev/null || true

## clean: Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@go clean
	@echo "✅ Clean complete"

## test: Run all tests (unit + integration)
test: test-unit test-integration

## test-unit: Run unit tests only
test-unit:
	@echo "🧪 Running unit tests..."
	@go test -v ./...

## test-integration: Run integration tests (requires running server)
test-integration:
	@echo "🧪 Running integration tests..."
	@./scripts/simple-test.sh

## test-dev: Build, start server, run tests, stop server
test-dev: build
	@echo "🧪 Running full development test cycle..."
	@./scripts/dev.sh $(DEFAULT_PORT) & \
	SERVER_PID=$$!; \
	sleep 2; \
	./scripts/test-server.sh; \
	TEST_RESULT=$$?; \
	kill $$SERVER_PID 2>/dev/null || true; \
	exit $$TEST_RESULT

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