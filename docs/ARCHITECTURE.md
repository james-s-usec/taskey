# Taskey Architecture

## Overview
Mental load fantasy draft app for couples to gamify household task management. Built as a responsive web application using Go for maximum simplicity and deployment ease.

## Tech Stack

### Backend & Frontend (Single Application)
- **Language**: Go 1.21+
- **Web Framework**: net/http with custom routing
- **Templating**: Templ (type-safe Go templates)
- **Interactivity**: HTMX for dynamic updates
- **Database**: SQLite with database/sql
- **Authentication**: Session-based with secure cookies
- **Styling**: Tailwind CSS for responsive design

### Mobile Strategy
- **Primary**: Responsive web app (mobile-first design)
- **PWA Features**: Service workers, offline capability
- **Add to Home Screen**: App-like experience on mobile
- **Future**: Native iOS app if needed (Go API backend ready)

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Browser Clients                          │
├─────────────────┬─────────────────┬─────────────────────────┤
│   Desktop Web   │   Mobile Web    │   PWA (Home Screen)     │
│                 │                 │                         │
└─────────────────┴─────────────────┴─────────────────────────┘
                            │
                            │ HTTP/WebSocket
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      Go Web Server                         │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   HTTP      │  │   Session   │  │     WebSocket       │  │
│  │  Handlers   │  │    Auth     │  │   (Real-time)       │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Templ     │  │   Static    │  │    Business         │  │
│  │ Templates   │  │   Assets    │  │     Logic           │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       SQLite DB                            │
├─────────────────────────────────────────────────────────────┤
│   Users  │  Households  │  Tasks  │  Drafts  │  Sessions   │
└─────────────────────────────────────────────────────────────┘

External Integrations (Future):
┌─────────────────┐
│ Google Calendar │  ◄─── HTTP API calls
│   Integration   │
└─────────────────┘
```

## Project Structure
```
taskey/
├── docs/                 # Documentation
├── cmd/                  # Application entry points
│   └── server/
│       └── main.go       # Main application
├── internal/             # Private application code
│   ├── handlers/         # HTTP handlers
│   ├── models/           # Data models
│   ├── database/         # Database operations
│   ├── auth/             # Authentication logic
│   └── templates/        # Templ template files
├── static/               # Static assets (CSS, JS, images)
│   ├── css/              # Tailwind CSS
│   ├── js/               # HTMX and custom JS
│   └── images/           # Application images
├── migrations/           # Database migrations
├── data/                 # SQLite database files
├── go.mod                # Go modules
└── go.sum                # Go dependencies
```

## Data Flow Architecture

### Request Flow
1. **Browser** sends HTTP request to Go server
2. **Router** matches URL to handler function
3. **Handler** processes request (auth, validation, business logic)
4. **Database** operations via SQLite queries
5. **Template** rendered with data using Templ
6. **Response** sent back as complete HTML page

### Interactive Flow (HTMX)
1. **User action** triggers HTMX request (click, form submit)
2. **Partial update** request sent to specific endpoint
3. **Handler** processes and returns HTML fragment
4. **HTMX** swaps content in DOM without page reload

### Real-time Flow (WebSocket)
1. **Draft session** creates WebSocket connection
2. **User actions** broadcast to all connected clients
3. **Server** manages draft state and pushes updates
4. **Clients** receive real-time draft picks and updates

## MVP Approach
1. **Single Binary**: One Go executable handles everything
2. **Server-Side Rendering**: Templates generate HTML, minimal JS
3. **Progressive Enhancement**: HTMX adds interactivity
4. **Session-Based Auth**: Secure cookies, no JWT complexity
5. **Mobile-First Design**: Responsive from day one

## Development Approach
1. **Templates-First**: Design HTML structure, then add handlers
2. **Database-Driven**: SQLite schema drives application structure
3. **HTMX Enhancement**: Add interactivity incrementally
4. **Single Language**: Go for all server-side logic