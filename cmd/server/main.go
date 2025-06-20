package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/james-s-usec/taskey/internal/config"
	"github.com/james-s-usec/taskey/internal/handlers"
	"github.com/james-s-usec/taskey/internal/middleware"
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

	// Wrap with middleware (order matters: recovery -> logging -> routes)
	var handler http.Handler = mux
	handler = middleware.LoggingMiddleware(handler)
	handler = middleware.RecoveryMiddleware(handler)

	// Create the server with configuration
	server := &http.Server{
		Addr:         ":" + cfg.Server.Port,
		Handler:      handler,
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

	// Set up graceful shutdown
	go func() {
		log.Printf("Server listening on port %s", cfg.Server.Port)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server failed to start: %v", err)
		}
	}()

	// Wait for interrupt signal to gracefully shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("🛑 Shutting down server...")

	// Give outstanding requests 30 seconds to complete
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if err := server.Shutdown(ctx); err != nil {
		log.Fatalf("Server forced to shutdown: %v", err)
	}

	log.Println("✅ Server shutdown complete")
}