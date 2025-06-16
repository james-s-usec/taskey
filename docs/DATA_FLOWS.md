# Data Flow Diagrams

## Overview
Detailed data flow diagrams for Taskey Go web application showing request/response patterns, authentication flow, and real-time interactions.

## 1. User Authentication Flow

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Browser   │    │   Handler   │    │  Database   │    │   Session   │
│             │    │             │    │             │    │   Store     │
└──────┬──────┘    └──────┬──────┘    └──────┬──────┘    └──────┬──────┘
       │                  │                  │                  │
       │ POST /login      │                  │                  │
       │ (email,password) │                  │                  │
       ├─────────────────►│                  │                  │
       │                  │ SELECT user WHERE│                  │
       │                  │ email = ?        │                  │
       │                  ├─────────────────►│                  │
       │                  │                  │                  │
       │                  │ User record      │                  │
       │                  │◄─────────────────┤                  │
       │                  │                  │                  │
       │                  │ bcrypt.Compare   │                  │
       │                  │ (password)       │                  │
       │                  │                  │                  │
       │                  │                  │ Create session   │
       │                  │                  │ (user_id,        │
       │                  │                  │  household_id)   │
       │                  ├─────────────────────────────────────►│
       │                  │                  │                  │
       │                  │                  │ Session ID       │
       │                  │◄─────────────────────────────────────┤
       │                  │                  │                  │
       │ Set-Cookie:      │                  │                  │
       │ session_id       │                  │                  │
       │ Redirect: /dashboard                │                  │
       │◄─────────────────┤                  │                  │
       │                  │                  │                  │
```

## 2. Page Request Flow (Server-Side Rendering)

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Browser   │    │ Auth Check  │    │   Handler   │    │  Template   │
│             │    │ Middleware  │    │             │    │  Engine     │
└──────┬──────┘    └──────┬──────┘    └──────┬──────┘    └──────┬──────┘
       │                  │                  │                  │
       │ GET /dashboard   │                  │                  │
       ├─────────────────►│                  │                  │
       │                  │ Check session    │                  │
       │                  │ cookie           │                  │
       │                  │                  │                  │
       │                  │ Extract user_id, │                  │
       │                  │ household_id     │                  │
       │                  │                  │                  │
       │                  │ Valid session    │                  │
       │                  ├─────────────────►│                  │
       │                  │                  │ Query dashboard  │
       │                  │                  │ data for         │
       │                  │                  │ household        │
       │                  │                  │                  │
       │                  │                  │ Render template  │
       │                  │                  │ with data        │
       │                  │                  ├─────────────────►│
       │                  │                  │                  │
       │                  │                  │ Complete HTML    │
       │                  │                  │◄─────────────────┤
       │ Complete HTML    │                  │                  │
       │ page             │                  │                  │
       │◄─────────────────┼─────────────────┼──────────────────┤
       │                  │                  │                  │
```

## 3. HTMX Partial Update Flow

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Browser   │    │    HTMX     │    │   Handler   │    │    DOM      │
│   (User)    │    │  Library    │    │             │    │             │
└──────┬──────┘    └──────┬──────┘    └──────┬──────┘    └──────┬──────┘
       │                  │                  │                  │
       │ Click button     │                  │                  │
       │ (mark complete)  │                  │                  │
       ├─────────────────►│                  │                  │
       │                  │ POST /tasks/123/ │                  │
       │                  │ complete         │                  │
       │                  ├─────────────────►│                  │
       │                  │                  │ Update task in   │
       │                  │                  │ database         │
       │                  │                  │                  │
       │                  │                  │ Render task HTML │
       │                  │                  │ fragment         │
       │                  │                  │                  │
       │                  │ HTML fragment    │                  │
       │                  │ (updated task)   │                  │
       │                  │◄─────────────────┤                  │
       │                  │                  │                  │
       │                  │ Swap content     │                  │
       │                  │ in DOM           │                  │
       │                  ├─────────────────────────────────────►│
       │                  │                  │                  │
       │ See updated UI   │                  │                  │
       │◄─────────────────┼─────────────────┼──────────────────┤
       │                  │                  │                  │
```

## 4. Draft System Real-time Flow

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Browser A  │    │ WebSocket   │    │   Server    │    │  Browser B  │
│  (User 1)   │    │  Handler    │    │             │    │  (User 2)   │
└──────┬──────┘    └──────┬──────┘    └──────┬──────┘    └──────┬──────┘
       │                  │                  │                  │
       │ Connect to       │                  │                  │
       │ /ws/draft/123    │                  │                  │
       ├─────────────────►│                  │                  │
       │                  │ Register client  │                  │
       │                  │ for draft 123    │                  │
       │                  ├─────────────────►│◄─────────────────┤
       │                  │                  │                  │ Connect to
       │                  │                  │                  │ /ws/draft/123
       │                  │                  │                  │
       │ Make draft pick  │                  │                  │
       │ (select task)    │                  │                  │
       ├─────────────────►│                  │                  │
       │                  │ Process pick     │                  │
       │                  │ Update database  │                  │
       │                  ├─────────────────►│                  │
       │                  │                  │                  │
       │                  │ Broadcast update │                  │
       │                  │ to all clients   │                  │
       │                  │◄─────────────────┤                  │
       │                  │                  │                  │
       │ Receive pick     │                  │ Receive pick     │
       │ update           │                  │ update           │
       │◄─────────────────┤                  ├─────────────────►│
       │                  │                  │                  │
       │ Update draft UI  │                  │ Update draft UI  │
       │                  │                  │                  │
```

## 5. Form Submission with Validation

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Browser   │    │   Handler   │    │ Validation  │    │  Database   │
│             │    │             │    │   Layer     │    │             │
└──────┬──────┘    └──────┬──────┘    └──────┬──────┘    └──────┬──────┘
       │                  │                  │                  │
       │ POST /tasks      │                  │                  │
       │ (form data)      │                  │                  │
       ├─────────────────►│                  │                  │
       │                  │ Parse form data  │                  │
       │                  │                  │                  │
       │                  │ Validate fields  │                  │
       │                  ├─────────────────►│                  │
       │                  │                  │                  │
       │                  │ Validation       │                  │
       │                  │ errors           │                  │
       │                  │◄─────────────────┤                  │
       │                  │                  │                  │
       │ HTML form with   │                  │                  │
       │ error messages   │                  │                  │
       │◄─────────────────┤                  │                  │
       │                  │                  │                  │
       │ Fix errors,      │                  │                  │
       │ resubmit         │                  │                  │
       ├─────────────────►│                  │                  │
       │                  │ Validate again   │                  │
       │                  ├─────────────────►│                  │
       │                  │                  │                  │
       │                  │ Valid data       │                  │
       │                  │◄─────────────────┤                  │
       │                  │                  │                  │
       │                  │ INSERT task      │                  │
       │                  ├─────────────────────────────────────►│
       │                  │                  │                  │
       │                  │ Task ID          │                  │
       │                  │◄─────────────────────────────────────┤
       │                  │                  │                  │
       │ Redirect to      │                  │                  │
       │ /tasks           │                  │                  │
       │◄─────────────────┤                  │                  │
       │                  │                  │                  │
```

## 6. Calendar View Data Assembly

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Browser   │    │ Calendar    │    │  Database   │    │  Template   │
│             │    │  Handler    │    │             │    │             │
└──────┬──────┘    └──────┬──────┘    └──────┬──────┘    └──────┬──────┘
       │                  │                  │                  │
       │ GET /calendar/   │                  │                  │
       │ 2024/01          │                  │                  │
       ├─────────────────►│                  │                  │
       │                  │ Parse month/year │                  │
       │                  │                  │                  │
       │                  │ Query tasks for  │                  │
       │                  │ date range       │                  │
       │                  ├─────────────────►│                  │
       │                  │                  │                  │
       │                  │ Tasks with       │                  │
       │                  │ due dates        │                  │
       │                  │◄─────────────────┤                  │
       │                  │                  │                  │
       │                  │ Group tasks by   │                  │
       │                  │ date             │                  │
       │                  │                  │                  │
       │                  │ Generate calendar│                  │
       │                  │ grid with tasks  │                  │
       │                  ├─────────────────────────────────────►│
       │                  │                  │                  │
       │                  │ Calendar HTML    │                  │
       │                  │◄─────────────────────────────────────┤
       │ Calendar page    │                  │                  │
       │ with tasks       │                  │                  │
       │◄─────────────────┤                  │                  │
       │                  │                  │                  │
```

## 7. Session Management Lifecycle

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Browser   │    │ Middleware  │    │  Sessions   │    │  Database   │
│             │    │             │    │   Store     │    │             │
└──────┬──────┘    └──────┬──────┘    └──────┬──────┘    └──────┬──────┘
       │                  │                  │                  │
       │ Any request      │                  │                  │
       │ with session     │                  │                  │
       │ cookie           │                  │                  │
       ├─────────────────►│                  │                  │
       │                  │ Extract session  │                  │
       │                  │ ID from cookie   │                  │
       │                  │                  │                  │
       │                  │ Load session     │                  │
       │                  │ data             │                  │
       │                  ├─────────────────►│                  │
       │                  │                  │ SELECT session  │
       │                  │                  │ WHERE id = ?     │
       │                  │                  ├─────────────────►│
       │                  │                  │                  │
       │                  │                  │ Session data     │
       │                  │                  │◄─────────────────┤
       │                  │ Session data     │                  │
       │                  │ (user_id,        │                  │
       │                  │  household_id)   │                  │
       │                  │◄─────────────────┤                  │
       │                  │                  │                  │
       │                  │ Add to request   │                  │
       │                  │ context          │                  │
       │                  │                  │                  │
       │                  │ Continue to      │                  │
       │                  │ handler          │                  │
       │                  │                  │                  │
```

## Data Security Patterns

### Household Isolation
Every database query includes household_id filter:
```sql
-- CORRECT
SELECT * FROM tasks WHERE household_id = ? AND id = ?

-- INCORRECT (Security Risk)
SELECT * FROM tasks WHERE id = ?
```

### Session Context
Every handler has access to authenticated user context:
```go
type RequestContext struct {
    UserID      int
    HouseholdID int
    User        *User
}
```

### Input Validation
All user inputs validated before database operations:
```go
func ValidateTaskForm(form TaskForm) []ValidationError {
    // Validate title, category, points, etc.
    // Return specific field errors
}
```