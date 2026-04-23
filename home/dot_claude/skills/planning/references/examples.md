# Planning Examples

## Example 1: Adding Authentication to a Web Application

### Context

The team wants to add user authentication to an existing web application. Currently, the application is publicly accessible with no user accounts or login mechanism. The goal is to implement a standard username/password authentication system with session management.

Scope includes:
- User registration and login functionality
- Password hashing and storage
- Session management
- Basic authorization (authenticated vs unauthenticated users)
- Login/logout UI

Out of scope:
- Third-party authentication (OAuth, social login)
- Role-based access control
- Password reset functionality

Success criteria:
- Users can register, login, and logout
- Sessions persist across page reloads
- Unauthorized users cannot access protected resources

### Approach

I recommend implementing a traditional session-based authentication system:

1. Create a users table in the database with fields for username, hashed password, and timestamps
2. Implement registration endpoint that validates input and stores hashed passwords
3. Implement login endpoint that verifies credentials and creates sessions
4. Add middleware to protect routes requiring authentication
5. Create frontend components for registration/login forms and user state management

This approach was chosen because:
- It's straightforward and well-understood
- Doesn't require third-party dependencies
- Provides good security when implemented correctly
- Fits naturally with the existing application architecture

Alternative approaches considered:
- JWT tokens: More complex for simple session management
- OAuth integration: Out of scope per requirements
- Serverless auth providers: Unnecessary complexity for this use case

### Steps

1. Create database migration for users table in `migrations/001_create_users_table.sql`
2. Add User model/entity in `src/models/user.js`
3. Implement password hashing utility in `src/utils/auth.js`
4. Create registration endpoint in `src/routes/auth.js`
5. Create login endpoint in `src/routes/auth.js`
6. Implement session middleware in `src/middleware/auth.js`
7. Add protected route example in `src/routes/profile.js`
8. Create registration form component in `src/components/RegisterForm.jsx`
9. Create login form component in `src/components/LoginForm.jsx`
10. Add authentication state management in `src/context/AuthContext.jsx`
11. Update main application to use authentication context in `src/App.jsx`
12. Add navigation updates to show login state in `src/components/Header.jsx`

### Risks

- **Password security**: High impact - Mitigation: Use established bcrypt library, enforce password complexity
- **Session hijacking**: Medium impact - Mitigation: Use secure cookies, regenerate session IDs, set appropriate cookie flags
- **Brute force attacks**: Medium impact - Mitigation: Implement rate limiting on auth endpoints
- **SQL injection**: High impact - Mitigation: Use parameterized queries, validate all inputs
- **User enumeration**: Low impact - Mitigation: Generic error messages for both failed login and registration

## Example 2: Refactoring Legacy Code Module

### Context

The legacy reporting module has become difficult to maintain due to tight coupling, lack of tests, and outdated patterns. The module generates various business reports but has frequent bugs and is slow to modify for new requirements.

The goal is to refactor this module to improve maintainability while preserving all existing functionality. This is part of a broader effort to modernize the codebase.

Scope:
- Refactor the reporting module components
- Maintain all existing report types and formats
- Improve code structure and testability
- Add basic unit tests for refactored code

Out of scope:
- Changing report functionality or output formats
- Database schema modifications
- Performance optimizations beyond what's necessary for refactoring

Success criteria:
- All existing reports continue to work identically
- Code follows current project standards
- Test coverage increased for refactored components
- Reduced coupling between components

### Approach

I recommend a gradual refactoring approach using the Strangler Fig pattern:

1. Identify stable interfaces and extract them first
2. Create new, well-structured implementations alongside legacy code
3. Gradually redirect calls from old to new implementations
4. Remove legacy code once fully replaced

This approach minimizes risk by:
- Keeping legacy code running during refactoring
- Allowing incremental progress
- Maintaining functionality throughout the process
- Providing natural rollback points

Alternative approaches considered:
- Big bang rewrite: Too risky for a critical module
- Complete abandonment: Doesn't meet requirements to preserve functionality

### Steps

1. Analyze current reporting module structure in `src/reports/legacy/`
2. Identify public interfaces and dependencies in `src/reports/index.js`
3. Create new `src/reports/v2/` directory for refactored code
4. Extract data access layer to `src/reports/v2/data.js`
5. Create new report generator base class in `src/reports/v2/base.js`
6. Implement individual report classes in `src/reports/v2/reports/*.js`
7. Add factory pattern for report instantiation in `src/reports/v2/factory.js`
8. Write unit tests for new components in `tests/reports/v2/`
9. Update integration tests to cover both old and new implementations
10. Modify router to use new implementation in `src/routes/reports.js`
11. Verify all reports work identically with new implementation
12. Remove legacy code in `src/reports/legacy/`

### Risks

- **Functionality drift**: High impact - Mitigation: Comprehensive test suite, exact output comparison
- **Performance regression**: Medium impact - Mitigation: Performance benchmarks, monitoring
- **Incomplete refactoring**: Medium impact - Mitigation: Track progress with checklist, incremental validation
- **Team unfamiliarity**: Low impact - Mitigation: Pair programming, knowledge sharing sessions