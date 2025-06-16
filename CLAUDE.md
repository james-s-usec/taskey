# Claude Memory - Taskey Project

## Development Workflow
- **Issue Tracking**: Use GitHub Issues for all todos and task management
- **Issue Templates**: Use .github/ISSUE_TEMPLATE/ for consistent issue creation
- **Commit Messages**: Follow docs/COMMIT_GUIDELINES.md format with issue references
- **No Internal Todo Lists**: Rely on GitHub Issues instead of TodoWrite tool

## Documentation Structure
- **docs/**: All documentation organized in dedicated folder
- **Planning**: docs/PLANNING.md, docs/ARCHITECTURE.md
- **API**: docs/API_DESIGN.md, docs/API_SPEC.yaml (OpenAPI 3.0)
- **Development**: docs/COMMIT_GUIDELINES.md, docs/README.md

## Tech Stack
- **Application**: Go web server (single binary)
- **Templates**: Templ for type-safe HTML generation
- **Interactivity**: HTMX for dynamic updates
- **Database**: SQLite with database/sql
- **Auth**: Session-based with secure cookies
- **Styling**: Tailwind CSS for responsive design
- **Mobile**: Responsive web app + PWA features

## Project Context
- Solo developer with AI assistance
- Mental load fantasy draft app for couples
- Fantasy football-style drafting of household tasks
- Single Go binary for web + mobile (responsive)
- Real-time draft features with WebSockets
- Calendar integration for task display
- Gamification with points and achievements