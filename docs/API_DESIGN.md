# API Design

## Versioning Strategy
- **Current Version**: v1
- **URL Pattern**: `/api/v{version}/`
- **Backwards Compatibility**: Maintain previous versions for 12 months minimum

## Base URLs
- Development: `http://localhost:3001/api/v1`
- Production: `https://api.taskey.app/v1`

## OpenAPI Specification
Full API specification available in [API_SPEC.yaml](./API_SPEC.yaml)

## Authentication
- JWT tokens in Authorization header: `Bearer <token>`
- Login endpoint returns access token
- Token includes user_id and household_id

## Version History
- **v1.0.0** (Current) - Initial API release

## Core Endpoints

### Authentication
```
POST /auth/register     # Register new user
POST /auth/login        # Login user
POST /auth/logout       # Logout user
GET  /auth/me          # Get current user info
```

### Users & Households
```
GET    /users/profile   # Get user profile
PUT    /users/profile   # Update user profile
GET    /households      # Get household info
POST   /households      # Create household
PUT    /households/:id  # Update household
```

### Tasks
```
GET    /tasks           # Get all tasks for household
POST   /tasks           # Create new task
GET    /tasks/:id       # Get specific task
PUT    /tasks/:id       # Update task
DELETE /tasks/:id       # Delete task
PATCH  /tasks/:id/complete  # Mark task complete
```

### Draft System
```
GET    /drafts          # Get draft history
POST   /drafts          # Create new draft session
GET    /drafts/:id      # Get specific draft
POST   /drafts/:id/pick # Make a draft pick
PUT    /drafts/:id/complete # Finalize draft
```

### Calendar
```
GET    /calendar        # Get calendar view with tasks
GET    /calendar/sync   # Trigger calendar sync
POST   /calendar/events # Create calendar event
```

## Data Models

### User
```json
{
  "id": 1,
  "email": "user@example.com",
  "name": "John Doe",
  "household_id": 1,
  "created_at": "2024-01-01T00:00:00Z"
}
```

### Task
```json
{
  "id": 1,
  "title": "Take out trash",
  "description": "Weekly trash pickup",
  "category": "cleaning",
  "points": 5,
  "assigned_to": 1,
  "created_by": 2,
  "due_date": "2024-01-07",
  "completed": false,
  "recurring": "weekly",
  "household_id": 1
}
```

### Draft
```json
{
  "id": 1,
  "household_id": 1,
  "draft_date": "2024-01-01",
  "status": "completed",
  "picks": [
    {
      "pick_order": 1,
      "user_id": 1,
      "task_id": 5
    }
  ]
}
```