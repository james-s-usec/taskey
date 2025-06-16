package handlers

import (
	"encoding/json"
	"net/http"
	"time"
)

// HealthResponse represents the health check response
type HealthResponse struct {
	Status    string `json:"status"`
	Service   string `json:"service"`
	Version   string `json:"version"`
	Timestamp string `json:"timestamp"`
}

// HealthHandler handles health check requests
type HealthHandler struct {
	serviceName string
	version     string
}

// NewHealthHandler creates a new health handler
func NewHealthHandler(serviceName, version string) *HealthHandler {
	return &HealthHandler{
		serviceName: serviceName,
		version:     version,
	}
}

// ServeHTTP implements the http.Handler interface
func (h *HealthHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	response := HealthResponse{
		Status:    "healthy",
		Service:   h.serviceName,
		Version:   h.version,
		Timestamp: time.Now().Format(time.RFC3339),
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)

	if err := json.NewEncoder(w).Encode(response); err != nil {
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}
}