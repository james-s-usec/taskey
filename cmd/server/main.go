package main

import (
	"fmt"
	"log"
	"net/http"
	"time"
)

func main() {
	// Create a new HTTP server mux
	mux := http.NewServeMux()

	// Basic routes for testing
	mux.HandleFunc("/", handleHome)
	mux.HandleFunc("/health", handleHealth)

	// Create the server
	server := &http.Server{
		Addr:         ":8080",
		Handler:      mux,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	fmt.Println("🚀 Taskey server starting on http://localhost:8080")
	fmt.Println("📖 Health check: http://localhost:8080/health")

	// Start the server
	if err := server.ListenAndServe(); err != nil {
		log.Fatal("Server failed to start:", err)
	}
}

// handleHome serves the main page
func handleHome(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}

	w.Header().Set("Content-Type", "text/html")
	fmt.Fprintf(w, `
<!DOCTYPE html>
<html>
<head>
    <title>Taskey - Mental Load Fantasy Draft</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            max-width: 600px; 
            margin: 50px auto; 
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 { color: #333; }
        .status { color: #28a745; }
        .next-steps { 
            background: #e7f3ff; 
            padding: 15px; 
            border-radius: 5px; 
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🏆 Taskey</h1>
        <p><strong>Mental Load Fantasy Draft for Couples</strong></p>
        <p class="status">✅ Go server is running successfully!</p>
        
        <div class="next-steps">
            <h3>🔧 Next Steps</h3>
            <ul>
                <li>Add database connection</li>
                <li>Create user authentication</li>
                <li>Build task management</li>
                <li>Implement draft system</li>
            </ul>
        </div>
        
        <p><small>Version: MVP Development | Port: 8080</small></p>
    </div>
</body>
</html>`)
}

// handleHealth provides a health check endpoint
func handleHealth(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	fmt.Fprintf(w, `{
    "status": "healthy",
    "service": "taskey",
    "version": "dev",
    "timestamp": "%s"
}`, time.Now().Format(time.RFC3339))
}