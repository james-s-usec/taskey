package main

// Simple main without graceful shutdown - for testing only
// Use: go run cmd/server/simple_main.go

import (
	"fmt"
	"log"
	"net/http"

	"github.com/james-s-usec/taskey/internal/config"
	"github.com/james-s-usec/taskey/internal/handlers"
	"github.com/james-s-usec/taskey/internal/middleware"
)

func main() {
	// Load configuration
	cfg := config.Load()

	// Create handlers
	homeHandler := handlers.NewHomeHandler(cfg.App.Name, cfg.App.Version, cfg.App.Environment)
	healthHandler := handlers.NewHealthHandler(cfg.App.Name, cfg.App.Version)

	// Create router
	mux := http.NewServeMux()
	mux.Handle("/", homeHandler)
	mux.Handle("/health", healthHandler)

	// Add middleware
	var handler http.Handler = mux
	handler = middleware.LoggingMiddleware(handler)
	handler = middleware.RecoveryMiddleware(handler)

	// Create server
	server := &http.Server{
		Addr:         ":" + cfg.Server.Port,
		Handler:      handler,
		ReadTimeout:  cfg.Server.ReadTimeout,
		WriteTimeout: cfg.Server.WriteTimeout,
		IdleTimeout:  cfg.Server.IdleTimeout,
	}

	// Log startup
	fmt.Printf("🚀 %s server starting\n", cfg.App.Name)
	fmt.Printf("🌍 Environment: %s\n", cfg.App.Environment)
	fmt.Printf("📡 Port: %s\n", cfg.Server.Port)
	fmt.Printf("🔗 URL: http://localhost:%s\n", cfg.Server.Port)
	fmt.Printf("💓 Health: http://localhost:%s/health\n", cfg.Server.Port)

	// Start server (blocks here - no graceful shutdown)
	log.Printf("Server listening on port %s", cfg.Server.Port)
	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}