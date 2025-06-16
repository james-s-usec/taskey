# Go Commands Reference

## Overview
Go has built-in commands similar to npm scripts. No package.json needed - everything is built into the `go` command.

## Essential Go Commands

### Project Management
```bash
# Initialize new Go module (like npm init)
go mod init github.com/james-s-usec/taskey

# Download and update dependencies (like npm install)
go mod tidy

# Download specific dependency
go get package-name

# Remove unused dependencies
go mod tidy
```

### Development Commands
```bash
# Run Go program directly (like npm start)
go run cmd/server/main.go

# Build binary executable
go build -o bin/taskey cmd/server/main.go

# Install program to $GOPATH/bin
go install cmd/server

# Format Go code (like prettier)
go fmt ./...

# Check for potential issues
go vet ./...
```

### Testing Commands
```bash
# Run all tests
go test ./...

# Run tests with coverage
go test -cover ./...

# Run tests in verbose mode
go test -v ./...

# Run specific test
go test -run TestFunctionName
```

### Package Management
```bash
# List all dependencies
go list -m all

# Show dependency graph
go mod graph

# Check for available updates
go list -u -m all

# Clean module cache
go clean -modcache
```

## Go vs npm Comparison

| Task | npm | Go |
|------|-----|-----|
| Initialize project | `npm init` | `go mod init` |
| Install dependencies | `npm install` | `go mod tidy` |
| Add dependency | `npm install package` | `go get package` |
| Run development | `npm start` | `go run main.go` |
| Build for production | `npm run build` | `go build` |
| Run tests | `npm test` | `go test ./...` |
| Format code | `npm run format` | `go fmt ./...` |

## Important Differences

### No package.json
- Go doesn't use package.json
- Dependencies listed in `go.mod` file
- No scripts section - use `go run` directly

### No node_modules
- Dependencies downloaded to Go module cache
- No local node_modules equivalent
- Much smaller project size

### Built-in Tools
- Formatting: `go fmt` (built-in, no prettier needed)
- Testing: `go test` (built-in, no jest needed)  
- Linting: `go vet` (built-in)
- Documentation: `go doc` (built-in)

## Common Development Workflow

### Starting Development
```bash
# Run server (auto-reloads on save with tools like air)
go run cmd/server/main.go

# Or build and run binary
go build -o bin/taskey cmd/server/main.go
./bin/taskey
```

### Adding Dependencies
```bash
# Example: Add SQLite driver
go get github.com/mattn/go-sqlite3

# Add HTTP router
go get github.com/gorilla/mux

# Update go.mod and go.sum files
go mod tidy
```

### Before Committing
```bash
# Format all code
go fmt ./...

# Check for issues
go vet ./...

# Run tests
go test ./...

# Update dependencies
go mod tidy
```

## Useful Tools (Optional)

### Air (Live Reloading)
```bash
# Install air for auto-restart on file changes
go install github.com/cosmtrek/air@latest

# Run with live reload
air
```

### Delve (Debugger)
```bash
# Install debugger
go install github.com/go-delve/delve/cmd/dlv@latest

# Debug program
dlv debug cmd/server/main.go
```

## Project Structure Commands

### Create Standard Directories
```bash
mkdir -p cmd/server
mkdir -p internal/{handlers,models,database,auth}
mkdir -p static/{css,js,images}
mkdir -p migrations
```

### Build for Different Platforms
```bash
# Build for Linux
GOOS=linux GOARCH=amd64 go build -o bin/taskey-linux cmd/server/main.go

# Build for Windows  
GOOS=windows GOARCH=amd64 go build -o bin/taskey.exe cmd/server/main.go

# Build for macOS
GOOS=darwin GOARCH=amd64 go build -o bin/taskey-mac cmd/server/main.go
```

## Go Module Files

### go.mod (like package.json)
```go
module github.com/james-s-usec/taskey

go 1.22

require (
    github.com/gorilla/mux v1.8.0
    github.com/mattn/go-sqlite3 v1.14.16
)
```

### go.sum (like package-lock.json)
Contains checksums of dependencies for security.