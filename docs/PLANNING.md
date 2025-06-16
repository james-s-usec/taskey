# Taskey - Mental Load Fantasy Draft App

## Tech Stack Decision
- **Application**: Go web server (single binary)
- **Templates**: Templ for type-safe HTML generation
- **Interactivity**: HTMX for dynamic updates
- **Database**: SQLite (simple, file-based)
- **Auth**: Session-based with secure cookies
- **Styling**: Tailwind CSS for responsive design
- **Mobile**: Responsive web app + PWA features
- **Deployment**: Single binary deployment anywhere

## Core Concept
Fantasy football-style draft system for household tasks and mental load between spouses.

## Feature Brainstorm

### Core Features (MVP)
- [ ] User registration/login (2 users max per household)
- [ ] Task creation and management
- [ ] Fantasy draft system for tasks
- [ ] Basic calendar view
- [ ] Task completion tracking

### Draft System Features
- [ ] "Draft day" - schedule drafting sessions
- [ ] Task categories (cleaning, errands, planning, etc.)
- [ ] Point values for tasks (mental load weighting)
- [ ] Draft history and stats

### Calendar Integration
- [ ] Display tasks on calendar
- [ ] Calendar sync (Google Calendar API)
- [ ] Recurring task scheduling
- [ ] Deadline tracking

### Gamification
- [ ] Points/scoring system
- [ ] Achievement badges
- [ ] Weekly/monthly stats
- [ ] "Trade" system for tasks

### Nice-to-Have
- [ ] Task templates
- [ ] Photo attachments for tasks
- [ ] Notifications/reminders
- [ ] Shared shopping lists
- [ ] Bill tracking integration

## Database Schema Ideas

### Users
- id, email, name, household_id

### Households  
- id, name, created_at

### Tasks
- id, title, description, points, category, assigned_to, created_by, due_date, completed

### Drafts
- id, household_id, draft_date, status (pending/active/completed)

### Draft_Picks
- id, draft_id, user_id, task_id, pick_order

## Next Steps
1. Confirm MVP scope
2. Set up Express + React project structure
3. Design API endpoints
4. Build authentication system