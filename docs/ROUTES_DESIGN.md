# Routes & Handler Design

## Overview
Go web application using standard HTTP handlers with Templ templates and HTMX for interactivity. Session-based authentication with secure cookies.

## Route Structure

### Authentication Routes
```
GET  /                    # Landing page (redirects if authenticated)
GET  /login              # Login form
POST /login              # Process login
GET  /register           # Registration form  
POST /register           # Process registration
POST /logout             # Logout and clear session
```

### Application Routes (Authenticated)
```
GET  /dashboard          # Main dashboard with task overview
GET  /tasks              # Task list view
GET  /tasks/new          # New task form
POST /tasks              # Create new task
GET  /tasks/{id}         # Task detail view
POST /tasks/{id}/edit    # Update task
POST /tasks/{id}/delete  # Delete task
POST /tasks/{id}/complete # Mark task complete
```

### Draft System Routes
```
GET  /drafts             # Draft history
GET  /drafts/new         # Create new draft form
POST /drafts             # Start new draft session
GET  /drafts/{id}        # Draft room (WebSocket enabled)
POST /drafts/{id}/pick   # Make draft pick (HTMX)
POST /drafts/{id}/complete # Finalize draft
```

### Calendar Routes
```
GET  /calendar           # Calendar view with tasks
GET  /calendar/{year}/{month} # Specific month view
```

### HTMX Partial Routes
```
GET  /htmx/tasks         # Task list fragment
GET  /htmx/calendar      # Calendar fragment
POST /htmx/task-quick    # Quick task creation
GET  /htmx/draft-status  # Draft status updates
```

### API Routes (Future Mobile/External)
```
GET  /api/health         # Health check
GET  /api/tasks          # JSON task list
POST /api/tasks          # Create task via JSON
```

## Handler Architecture

### Handler Structure
```go
type Handler struct {
    db       *sql.DB
    sessions *sessions.CookieStore
    logger   *log.Logger
}

func (h *Handler) HandleDashboard(w http.ResponseWriter, r *http.Request) {
    // 1. Check authentication
    // 2. Get user/household from session
    // 3. Query database for dashboard data
    // 4. Render template with data
    // 5. Return HTML response
}
```

### Template Data Patterns
```go
type DashboardData struct {
    User          *User
    Household     *Household
    RecentTasks   []Task
    UpcomingTasks []Task
    DraftStatus   *DraftStatus
}

type TaskListData struct {
    User  *User
    Tasks []Task
    Filter TaskFilter
}
```

## Authentication Flow

### Session Management
```go
// Login process
1. Validate credentials
2. Create session with user ID and household ID
3. Set secure HTTP-only cookie
4. Redirect to dashboard

// Request authentication
1. Read session cookie
2. Validate session in store
3. Extract user/household context
4. Continue to handler or redirect to login
```

### Middleware Chain
```go
router.Use(LoggingMiddleware)
router.Use(SessionMiddleware)

// Protected routes
protected := router.PathPrefix("/").Subrouter()
protected.Use(AuthRequiredMiddleware)
```

## HTMX Integration Patterns

### Form Submissions
```html
<!-- Traditional form with HTMX enhancement -->
<form hx-post="/tasks" hx-target="#task-list" hx-swap="afterbegin">
    <input name="title" required>
    <button type="submit">Add Task</button>
</form>
```

### Dynamic Updates
```html
<!-- Auto-refreshing draft status -->
<div hx-get="/htmx/draft-status" 
     hx-trigger="every 2s" 
     hx-target="this">
    <!-- Draft status content -->
</div>
```

### Real-time Features
```html
<!-- WebSocket for live draft updates -->
<div id="draft-room" 
     hx-ext="ws" 
     ws-connect="/ws/draft/{id}">
    <!-- Live draft content -->
</div>
```

## Data Models

### Core Models
```go
type User struct {
    ID          int       `db:"id"`
    Email       string    `db:"email"`
    Name        string    `db:"name"`
    PasswordHash string   `db:"password_hash"`
    HouseholdID int       `db:"household_id"`
    CreatedAt   time.Time `db:"created_at"`
}

type Task struct {
    ID          int       `db:"id"`
    Title       string    `db:"title"`
    Description string    `db:"description"`
    Category    string    `db:"category"`
    Points      int       `db:"points"`
    AssignedTo  *int      `db:"assigned_to"`
    CreatedBy   int       `db:"created_by"`
    DueDate     *time.Time `db:"due_date"`
    Completed   bool      `db:"completed"`
    CompletedAt *time.Time `db:"completed_at"`
    HouseholdID int       `db:"household_id"`
    CreatedAt   time.Time `db:"created_at"`
    UpdatedAt   time.Time `db:"updated_at"`
}

type Draft struct {
    ID          int         `db:"id"`
    HouseholdID int         `db:"household_id"`
    DraftDate   time.Time   `db:"draft_date"`
    Status      string      `db:"status"` // pending, active, completed
    CurrentPick int         `db:"current_pick"`
    CreatedAt   time.Time   `db:"created_at"`
    Picks       []DraftPick `json:"picks"`
}
```

## Error Handling

### HTTP Error Responses
```go
func (h *Handler) renderError(w http.ResponseWriter, r *http.Request, status int, message string) {
    w.WriteHeader(status)
    data := ErrorData{
        Status:  status,
        Message: message,
        User:    getUserFromSession(r),
    }
    h.templates.Render(w, "error.html", data)
}
```

### Form Validation
```go
type TaskForm struct {
    Title       string `validate:"required,min=1,max=100"`
    Description string `validate:"max=500"`
    Category    string `validate:"required,oneof=cleaning errands planning cooking"`
    Points      int    `validate:"required,min=1,max=10"`
}
```

## Development Workflow

### Template Development
1. Create HTML template with Templ
2. Define data structure
3. Create handler to populate data
4. Wire up route
5. Add HTMX enhancement if needed

### Database Operations
1. Write SQL query/migration
2. Create model struct
3. Implement database methods
4. Use in handlers
5. Test with real data