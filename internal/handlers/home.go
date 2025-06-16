package handlers

import (
	"fmt"
	"net/http"
)

// HomeHandler handles home page requests
type HomeHandler struct {
	appName    string
	version    string
	environment string
}

// NewHomeHandler creates a new home handler
func NewHomeHandler(appName, version, environment string) *HomeHandler {
	return &HomeHandler{
		appName:     appName,
		version:     version,
		environment: environment,
	}
}

// ServeHTTP implements the http.Handler interface
func (h *HomeHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	// Only serve on exact root path
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}

	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.WriteHeader(http.StatusOK)

	fmt.Fprintf(w, h.getHomePageHTML())
}

// getHomePageHTML returns the HTML for the home page
func (h *HomeHandler) getHomePageHTML() string {
	return fmt.Sprintf(`<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>%s - Mental Load Fantasy Draft</title>
    <style>
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            max-width: 800px; 
            margin: 50px auto; 
            padding: 20px;
            background-color: #f8fafc;
            line-height: 1.6;
        }
        .container {
            background: white;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        }
        h1 { 
            color: #1e293b; 
            margin-bottom: 10px;
        }
        .subtitle {
            color: #64748b;
            font-size: 18px;
            margin-bottom: 30px;
        }
        .status { 
            color: #059669; 
            font-weight: 600;
            font-size: 18px;
            margin: 20px 0;
        }
        .next-steps { 
            background: #eff6ff; 
            padding: 20px; 
            border-radius: 8px; 
            margin-top: 30px;
            border-left: 4px solid #3b82f6;
        }
        .next-steps h3 {
            color: #1e40af;
            margin-top: 0;
        }
        .next-steps ul {
            margin-bottom: 0;
        }
        .next-steps li {
            margin: 8px 0;
        }
        .footer {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #e2e8f0;
            color: #64748b;
            font-size: 14px;
        }
        .env-info {
            background: #f1f5f9;
            padding: 15px;
            border-radius: 6px;
            margin: 20px 0;
            font-family: 'Monaco', 'Menlo', monospace;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🏆 %s</h1>
        <p class="subtitle">Mental Load Fantasy Draft for Couples</p>
        
        <p class="status">✅ Go server is running successfully!</p>
        
        <div class="env-info">
            <strong>Environment:</strong> %s<br>
            <strong>Version:</strong> %s<br>
            <strong>Port:</strong> 8080
        </div>
        
        <div class="next-steps">
            <h3>🔧 Development Roadmap</h3>
            <ul>
                <li>✅ <strong>Project Setup</strong> - Go server with proper configuration</li>
                <li>🔄 <strong>Database Layer</strong> - SQLite connection and migrations</li>
                <li>⏳ <strong>Authentication</strong> - Session-based user login</li>
                <li>⏳ <strong>Task Management</strong> - CRUD operations for household tasks</li>
                <li>⏳ <strong>Draft System</strong> - Real-time fantasy draft with WebSockets</li>
                <li>⏳ <strong>Calendar View</strong> - Visual task scheduling</li>
                <li>⏳ <strong>Mobile Polish</strong> - Responsive design and PWA features</li>
            </ul>
        </div>
        
        <div class="footer">
            <strong>API Endpoints:</strong><br>
            🏠 <a href="/">Home</a> | 
            💓 <a href="/health">Health Check</a><br><br>
            
            <strong>Documentation:</strong> 
            <a href="https://github.com/james-s-usec/taskey/tree/main/docs" target="_blank">
                View on GitHub →
            </a>
        </div>
    </div>
</body>
</html>`, h.appName, h.appName, h.environment, h.version)
}