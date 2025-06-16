# Commit Message Guidelines

## Format
```
<type>(scope): <subject>

<body>

Closes #<issue-number>
```

## Types
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation only changes
- **style**: Changes that don't affect code meaning (white-space, formatting)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **test**: Adding missing tests
- **chore**: Changes to build process or auxiliary tools

## Scopes
- **api**: Backend API changes
- **ui**: Frontend UI changes
- **db**: Database changes
- **auth**: Authentication related
- **draft**: Fantasy draft system
- **calendar**: Calendar integration

## Examples

### Feature
```
feat(draft): add task drafting system

- Implement draft room with real-time updates
- Add draft order randomization
- Create draft history tracking

Closes #12
```

### Bug Fix
```
fix(api): resolve task deletion error

- Fix cascade delete for task dependencies
- Add proper error handling for missing tasks
- Update error messages for clarity

Closes #24
```

### Task/Chore
```
chore(setup): initialize Express server

- Set up basic Express server structure
- Add middleware for CORS and JSON parsing
- Configure SQLite database connection

Closes #5
```

## Rules
1. Use present tense ("add feature" not "added feature")
2. Use imperative mood ("move cursor to..." not "moves cursor to...")
3. Don't capitalize first letter of subject
4. No period at end of subject
5. Always reference the issue number
6. Body should explain what and why, not how