# Database Schema

## Overview
SQLite database schema for Taskey application. Designed for simplicity and household data isolation.

## Schema Design

### Core Tables

#### users
```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    household_id INTEGER NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (household_id) REFERENCES households(id)
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_household ON users(household_id);
```

#### households
```sql
CREATE TABLE households (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

#### tasks
```sql
CREATE TABLE tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    category TEXT NOT NULL CHECK (category IN ('cleaning', 'errands', 'planning', 'cooking', 'maintenance', 'childcare', 'other')),
    points INTEGER NOT NULL CHECK (points >= 1 AND points <= 10),
    assigned_to INTEGER,
    created_by INTEGER NOT NULL,
    due_date DATE,
    completed BOOLEAN DEFAULT FALSE,
    completed_at DATETIME,
    recurring TEXT DEFAULT 'none' CHECK (recurring IN ('none', 'daily', 'weekly', 'monthly')),
    household_id INTEGER NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (assigned_to) REFERENCES users(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (household_id) REFERENCES households(id)
);

CREATE INDEX idx_tasks_household ON tasks(household_id);
CREATE INDEX idx_tasks_assigned ON tasks(assigned_to);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_completed ON tasks(completed);
```

#### drafts
```sql
CREATE TABLE drafts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    household_id INTEGER NOT NULL,
    draft_date DATE NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'completed', 'cancelled')),
    current_pick INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (household_id) REFERENCES households(id)
);

CREATE INDEX idx_drafts_household ON drafts(household_id);
CREATE INDEX idx_drafts_status ON drafts(status);
```

#### draft_picks
```sql
CREATE TABLE draft_picks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    draft_id INTEGER NOT NULL,
    pick_order INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    task_id INTEGER NOT NULL,
    picked_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (draft_id) REFERENCES drafts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (task_id) REFERENCES tasks(id),
    UNIQUE(draft_id, pick_order),
    UNIQUE(draft_id, task_id)
);

CREATE INDEX idx_draft_picks_draft ON draft_picks(draft_id);
CREATE INDEX idx_draft_picks_order ON draft_picks(draft_id, pick_order);
```

#### sessions
```sql
CREATE TABLE sessions (
    id TEXT PRIMARY KEY,
    user_id INTEGER NOT NULL,
    household_id INTEGER NOT NULL,
    data TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (household_id) REFERENCES households(id)
);

CREATE INDEX idx_sessions_user ON sessions(user_id);
CREATE INDEX idx_sessions_expires ON sessions(expires_at);
```

## Data Relationships

```
households (1) ────┬─── (n) users
                   │
                   ├─── (n) tasks
                   │
                   └─── (n) drafts ──── (n) draft_picks
                                            │
                                            ├─── (1) users
                                            │
                                            └─── (1) tasks

users (1) ─────────┬─── (n) tasks (created_by)
                   │
                   ├─── (n) tasks (assigned_to)
                   │
                   ├─── (n) draft_picks
                   │
                   └─── (n) sessions
```

## Sample Data

### Households
```sql
INSERT INTO households (name) VALUES 
('Smith Family'),
('Johnson Household');
```

### Users
```sql
INSERT INTO users (email, name, password_hash, household_id) VALUES
('john@example.com', 'John Smith', '$2a$10$...', 1),
('jane@example.com', 'Jane Smith', '$2a$10$...', 1);
```

### Tasks
```sql
INSERT INTO tasks (title, description, category, points, created_by, household_id) VALUES
('Take out trash', 'Weekly trash and recycling pickup', 'cleaning', 3, 1, 1),
('Grocery shopping', 'Weekly grocery run for the family', 'errands', 5, 1, 1),
('Plan dinner menu', 'Plan meals for the upcoming week', 'planning', 4, 2, 1),
('Vacuum living room', 'Vacuum the main living areas', 'cleaning', 2, 2, 1);
```

## Queries

### Common Queries

#### Get household tasks
```sql
SELECT t.*, 
       creator.name as created_by_name,
       assignee.name as assigned_to_name
FROM tasks t
LEFT JOIN users creator ON t.created_by = creator.id
LEFT JOIN users assignee ON t.assigned_to = assignee.id
WHERE t.household_id = ?
ORDER BY t.created_at DESC;
```

#### Get user's assigned tasks
```sql
SELECT * FROM tasks 
WHERE assigned_to = ? AND household_id = ? AND completed = FALSE
ORDER BY due_date ASC, points DESC;
```

#### Get active draft with picks
```sql
SELECT d.*, 
       dp.pick_order, dp.picked_at,
       u.name as picker_name,
       t.title as task_title, t.points
FROM drafts d
LEFT JOIN draft_picks dp ON d.id = dp.draft_id
LEFT JOIN users u ON dp.user_id = u.id
LEFT JOIN tasks t ON dp.task_id = t.id
WHERE d.household_id = ? AND d.status = 'active'
ORDER BY dp.pick_order;
```

#### Get household stats
```sql
SELECT 
    COUNT(*) as total_tasks,
    COUNT(CASE WHEN completed THEN 1 END) as completed_tasks,
    COUNT(CASE WHEN assigned_to = ? THEN 1 END) as my_tasks,
    SUM(CASE WHEN assigned_to = ? AND completed THEN points ELSE 0 END) as my_points
FROM tasks 
WHERE household_id = ?;
```

## Migrations

### Migration System
```go
type Migration struct {
    Version int
    Name    string
    SQL     string
}

var migrations = []Migration{
    {1, "create_initial_tables", "CREATE TABLE households..."},
    {2, "add_task_categories", "ALTER TABLE tasks..."},
    {3, "add_sessions_table", "CREATE TABLE sessions..."},
}
```

### Migration Runner
```go
func RunMigrations(db *sql.DB) error {
    // Create migrations table if not exists
    // Check current version
    // Run pending migrations
    // Update version
}
```

## Data Isolation

### Household Security
- All data queries MUST include household_id filter
- Session contains user_id AND household_id
- No cross-household data access possible

### Query Patterns
```go
// CORRECT - Always filter by household
func GetTasks(db *sql.DB, householdID int) ([]Task, error) {
    query := "SELECT * FROM tasks WHERE household_id = ?"
    // ...
}

// INCORRECT - Missing household filter
func GetTasks(db *sql.DB) ([]Task, error) {
    query := "SELECT * FROM tasks" // ❌ SECURITY ISSUE
    // ...
}
```

## Performance Considerations

### Indexing Strategy
- Primary keys (automatic)
- Foreign keys for joins
- Household ID on all main tables
- Query-specific indexes (due_date, completed, etc.)

### Query Optimization
- Use LIMIT for pagination
- Index on commonly filtered columns
- Avoid N+1 queries with JOINs
- Use prepared statements

### Maintenance
- Regular VACUUM for SQLite optimization
- Monitor query performance
- Add indexes as needed based on usage patterns