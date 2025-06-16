# Taskey Architecture

## Overview
Mental load fantasy draft app for couples to gamify household task management.

## Tech Stack

### Backend
- **Framework**: Express.js
- **Database**: SQLite (simple, file-based)
- **Authentication**: JWT tokens
- **API Style**: RESTful

### Frontend
- **Framework**: React
- **State Management**: Context API (start simple)
- **Styling**: CSS Modules or Tailwind
- **Build Tool**: Vite

### Future Mobile
- **Framework**: React Native
- **Shared Logic**: API client and utilities

## System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React Web     │    │   React Native  │    │   External APIs │
│                 │    │     (Future)    │    │                 │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│                 │    │                 │    │ Google Calendar │
│   Frontend      │◄──►│   Mobile App    │    │   Integration   │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Express API   │
                    │                 │
                    ├─────────────────┤
                    │                 │
                    │   JWT Auth      │
                    │   Task Management│
                    │   Draft System  │
                    │   Calendar Sync │
                    │                 │
                    └─────────────────┘
                                 │
                    ┌─────────────────┐
                    │   SQLite DB     │
                    │                 │
                    ├─────────────────┤
                    │                 │
                    │   Users         │
                    │   Households    │
                    │   Tasks         │
                    │   Drafts        │
                    │   Calendar      │
                    │                 │
                    └─────────────────┘
```

## Project Structure
```
taskey/
├── docs/                 # Documentation
├── server/               # Express.js backend
│   ├── src/
│   │   ├── routes/       # API routes
│   │   ├── models/       # Database models
│   │   ├── middleware/   # Auth, validation, etc.
│   │   └── services/     # Business logic
│   └── database/         # SQLite files
├── client/               # React frontend
│   ├── src/
│   │   ├── components/   # React components
│   │   ├── pages/        # Page components
│   │   ├── services/     # API calls
│   │   └── utils/        # Utilities
└── mobile/               # React Native (future)
```

## MVP Approach
1. **Start Simple**: Basic CRUD operations, console.log for debugging
2. **Iterate Fast**: Add features as needed, don't over-engineer
3. **SQLite + JWT**: Minimal setup, no complex auth flows
4. **Basic Error Handling**: Simple try/catch, user-friendly messages
5. **Mobile Later**: Focus on web app first

## Development Approach
1. **API-First**: Design endpoints before implementation
2. **Mobile-Ready**: Structure for easy React Native addition
3. **KISS Principle**: Keep it simple, add complexity only when needed