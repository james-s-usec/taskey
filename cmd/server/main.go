package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/james-s-usec/taskey/internal/config"
	"github.com/james-s-usec/taskey/internal/handlers"
)

func main() {
	// Load configuration from environment variables
	cfg := config.Load()

	// Create handlers with dependency injection
	homeHandler := handlers.NewHomeHandler(cfg.App.Name, cfg.App.Version, cfg.App.Environment)
	healthHandler := handlers.NewHealthHandler(cfg.App.Name, cfg.App.Version)

	// Create router and register routes
	mux := http.NewServeMux()
	mux.Handle("/", homeHandler)
	mux.Handle("/health", healthHandler)

	// Create the server with configuration
	server := &http.Server{
		Addr:         ":" + cfg.Server.Port,
		Handler:      mux,
		ReadTimeout:  cfg.Server.ReadTimeout,
		WriteTimeout: cfg.Server.WriteTimeout,
		IdleTimeout:  cfg.Server.IdleTimeout,
	}

	// Log startup information
	fmt.Printf("🚀 %s server starting\n", cfg.App.Name)
	fmt.Printf("🌍 Environment: %s\n", cfg.App.Environment)
	fmt.Printf("📡 Port: %s\n", cfg.Server.Port)
	fmt.Printf("🔗 URL: http://localhost:%s\n", cfg.Server.Port)
	fmt.Printf("💓 Health: http://localhost:%s/health\n", cfg.Server.Port)

	// Start the server
	log.Printf("Server listening on port %s", cfg.Server.Port)
	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}