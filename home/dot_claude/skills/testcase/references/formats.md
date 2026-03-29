# /testcase File Templates & Maintenance Guide

This document provides templates for `tests/testlist.md` and `tests/TDD.md`, ID naming conventions, maintenance guidelines, and estimation conversion tables.

---

## tests/testlist.md Template

```markdown
# Test Case List

> Created: YYYY-MM-DD
> Target: [Project Name]
> Total Test Cases: XX (P0: X, P1: X, P2: X, P3: X)
> Estimated Total Effort: XX hours

---

## Summary

| Category   | Test Count | P0    | P1    | P2    | P3    | Est. Effort | Implemented |
| ---------- | ---------- | ----- | ----- | ----- | ----- | ----------- | ----------- |
| [Module A] | X          | X     | X     | X     | X     | Xh          | X/X         |
| [Module B] | X          | X     | X     | X     | X     | Xh          | X/X         |
| **Total**  | **X**      | **X** | **X** | **X** | **X** | **Xh**      | **X/X**     |

---

## [Module Name / Feature Name]

### TC-001: [Test Case Name]

- **Priority**: P0 / P1 / P2 / P3
- **Type**: Unit Test / Integration Test / E2E
- **Size**: S / M / L
- **Status**: [ ] Todo / [x] Done / [~] Updating
- **Target**: `src/path/to/module.ts` -> `functionName()`
- **Preconditions**: [State or data required for the test]
- **Input**: [Specific example of test input]
- **Expected Output**: [Expected result]
- **Test File**: `tests/path/to/module.test.ts`
- **Notes**: [Edge cases, precautions, or related TC-XXX references]
```

### Test Case ID Convention

- Use the format `TC-[3-digit sequence]` (e.g., TC-001, TC-002, ...).
- Group by module, but maintain a continuous sequence across the project.
- Do not reuse IDs even if a test case is deleted.
- Use `→ TC-XXX` in the Notes section for cross-references.

---

## tests/TDD.md Template

````markdown
# TDD Practice Guide & Progress Tracking

> Last Updated: YYYY-MM-DD

---

## TDD Cycle Rules

### Red → Green → Refactor

1. **Red**: Write exactly one test and confirm it fails as expected.
2. **Green**: Write the minimal code required to make that test pass.
3. **Refactor**: Improve the design while maintaining the Green state.

### Project-Specific Rules

- Write tests one at a time (no upfront mass-testing).
- Re-evaluate for refactoring immediately after every Green.
- Map test cases to `testlist.md` using `TC-XXX` IDs.
- Include the ID in commit messages (e.g., `test(auth): add JWT validation (TC-003)`).

---

## Test Execution Commands

```bash
# Run all tests
[Project specific command, e.g., npm test]

# Run specific test
[Project specific command, e.g., vitest path/to/file]

# Watch mode
[Project specific command]

# Run with coverage
[Project specific command]
```
````

---

## Implementation Roadmap (TDD Backlog)

### Sprint 1: Foundational Tests (P0)

| Order | ID     | Test Case Name | Size | Status | Date Completed |
| ----- | ------ | -------------- | ---- | ------ | -------------- |
| 1     | TC-001 | [Name]         | S    | [ ]    | -              |
| 2     | TC-002 | [Name]         | M    | [ ]    | -              |

### Sprint 2: Core Feature Tests (P1)

| Order | ID  | Test Case Name | Size | Status | Date Completed |
| ----- | --- | -------------- | ---- | ------ | -------------- |
| ...   | ... | ...            | ...  | ...    | ...            |

---

## Progress Dashboard

### Overall Progress

- **Total Cases**: XX
- **Implemented**: XX (XX%)
- **Passing**: XX
- **Failing**: XX
- **Todo**: XX

### Coverage Status

- **Statements**: XX%
- **Branches**: XX%
- **Functions**: XX%
- **Lines**: XX%

### Recent Activity Log

| Date       | ID     | Action      | Notes |
| ---------- | ------ | ----------- | ----- |
| YYYY-MM-DD | TC-001 | Implemented | -     |

```

---

## Test Code Maintenance Guidelines

### When a Test Fails

1. **Isolate the Cause**: Determine if it's a bug in the production code or if the test expectations are outdated.
2. **Production Bug**: Fix the code to pass the test.
3. **Spec Change**: Update the test case and synchronize `testlist.md`.
4. **Design Flaw**: Refactor the test itself if it has become fragile.

### When Adding New Features

1. Add a new test case to `testlist.md` (assign a new `TC-XXX`).
2. Set Priority and Size.
3. Integrate into the implementation roadmap in `TDD.md`.
4. Follow the Red → Green → Refactor cycle for implementation.

---

## Effort Estimation Table

Use the following hours to convert sizes (S/M/L) in `testlist.md`. This helps in Sprint planning and resource allocation.

| Size | Hours | Description |
| ---- | ----- | ----------- |
| **S** | 0.5h | Simple logic, no external dependencies. |
| **M** | 1.5h | Standard logic, involves mocking or multiple modules. |
| **L** | 6.0h | Complex integration, E2E, or heavy data setup. |

*Example: 10 S-sized + 8 M-sized + 3 L-sized = 5h + 12h + 18h = **35h (~4.5 man-days)***
```

---

## Filled Example: Hono + Cloudflare Workers API

A filled-in testlist.md for a Hono REST API project. Use this as a reference when generating test case lists.

```markdown
# Test Case List

> Created: 2026-03-29
> Target: Hono + Cloudflare Workers User Management API
> Total Test Cases: 12 (P0: 4, P1: 5, P2: 2, P3: 1)
> Estimated Total Effort: 18h

---

## Summary

| Category      | Test Count | P0 | P1 | P2 | P3 | Est. Effort | Implemented |
| ------------- | ---------- | -- | -- | -- | -- | ----------- | ----------- |
| Auth          | 4          | 2  | 2  | 0  | 0  | 6h          | 0/4         |
| Users (CRUD)  | 6          | 2  | 2  | 1  | 1  | 9h          | 0/6         |
| Middleware    | 2          | 0  | 1  | 1  | 0  | 3h          | 0/2         |
| **Total**     | **12**     | **4** | **5** | **2** | **1** | **18h** | **0/12** |

---

## Auth

### TC-001: POST /api/auth/login — valid credentials

- **Priority**: P0
- **Type**: Integration Test
- **Size**: M
- **Status**: [ ] Todo
- **Target**: `src/routes/auth.ts` -> `POST /api/auth/login`
- **Preconditions**: A user with email `test@example.com` and password `password123` exists in D1
- **Input**: `{ email: "test@example.com", password: "password123" }`
- **Expected Output**: HTTP 200, body contains `{ token: "<jwt>" }`
- **Test File**: `src/routes/auth.test.ts`
- **Notes**: Verify JWT structure (header.payload.signature). See TC-003 for protected route usage.

### TC-002: POST /api/auth/login — wrong password

- **Priority**: P0
- **Type**: Integration Test
- **Size**: S
- **Status**: [ ] Todo
- **Target**: `src/routes/auth.ts` -> `POST /api/auth/login`
- **Preconditions**: User exists in D1
- **Input**: `{ email: "test@example.com", password: "wrongpassword" }`
- **Expected Output**: HTTP 401, body `{ error: "Invalid credentials" }`
- **Test File**: `src/routes/auth.test.ts`
- **Notes**: Ensure timing-safe comparison to prevent timing attacks.

### TC-003: POST /api/auth/login — non-existent user

- **Priority**: P1
- **Type**: Integration Test
- **Size**: S
- **Status**: [ ] Todo
- **Target**: `src/routes/auth.ts` -> `POST /api/auth/login`
- **Preconditions**: No user with the given email in D1
- **Input**: `{ email: "nobody@example.com", password: "anything" }`
- **Expected Output**: HTTP 401, body `{ error: "Invalid credentials" }`
- **Test File**: `src/routes/auth.test.ts`
- **Notes**: Must return same error as TC-002 (no user enumeration).

### TC-004: POST /api/auth/login — malformed request body

- **Priority**: P1
- **Type**: Unit Test
- **Size**: S
- **Status**: [ ] Todo
- **Target**: `src/routes/auth.ts` -> Zod validation
- **Preconditions**: None
- **Input**: `{ email: "not-an-email" }` (missing password, invalid email)
- **Expected Output**: HTTP 400, body contains Zod validation errors
- **Test File**: `src/routes/auth.test.ts`
- **Notes**: Validated by `zValidator` middleware before handler runs.

---

## Users (CRUD)

### TC-005: POST /api/users — create new user

- **Priority**: P0
- **Type**: Integration Test
- **Size**: M
- **Status**: [ ] Todo
- **Target**: `src/routes/users.ts` -> `POST /api/users`
- **Preconditions**: No user with `newuser@example.com` in D1
- **Input**: `{ name: "Alice", email: "newuser@example.com", password: "secure123" }`
- **Expected Output**: HTTP 201, body `{ id: "<uuid>", name: "Alice", email: "newuser@example.com" }`
- **Test File**: `src/routes/users.test.ts`
- **Notes**: Password must NOT appear in response. UUID format: hex(randomblob(16)).

### TC-006: POST /api/users — duplicate email

- **Priority**: P0
- **Type**: Integration Test
- **Size**: S
- **Status**: [ ] Todo
- **Target**: `src/routes/users.ts` -> `POST /api/users`
- **Preconditions**: User with `test@example.com` already exists in D1
- **Input**: `{ name: "Bob", email: "test@example.com", password: "secure123" }`
- **Expected Output**: HTTP 409, body `{ error: "Email already in use" }`
- **Test File**: `src/routes/users.test.ts`
- **Notes**: D1 UNIQUE constraint on email column triggers this path.

### TC-007: GET /api/users/:id — fetch own profile (authenticated)

- **Priority**: P1
- **Type**: Integration Test
- **Size**: M
- **Status**: [ ] Todo
- **Target**: `src/routes/users.ts` -> `GET /api/users/:id`
- **Preconditions**: User exists; valid JWT for that user
- **Input**: Bearer token in Authorization header, `:id` = own user ID
- **Expected Output**: HTTP 200, body `{ id, name, email, created }`
- **Test File**: `src/routes/users.test.ts`
- **Notes**: Uses `testClient` from Hono. See TC-008 for unauthorized case.

### TC-008: GET /api/users/:id — no token (unauthorized)

- **Priority**: P1
- **Type**: Integration Test
- **Size**: S
- **Status**: [ ] Todo
- **Target**: `src/middleware/auth.ts` -> Bearer token check
- **Preconditions**: None
- **Input**: No Authorization header
- **Expected Output**: HTTP 401
- **Test File**: `src/routes/users.test.ts`
- **Notes**: Auth middleware must short-circuit before the handler. → TC-007

### TC-009: DELETE /api/users/:id — delete own account

- **Priority**: P2
- **Type**: Integration Test
- **Size**: M
- **Status**: [ ] Todo
- **Target**: `src/routes/users.ts` -> `DELETE /api/users/:id`
- **Preconditions**: User exists; valid JWT
- **Input**: Bearer token, `:id` = own user ID
- **Expected Output**: HTTP 204 No Content
- **Test File**: `src/routes/users.test.ts`
- **Notes**: Row must be removed from D1. Subsequent GET should return 404.

### TC-010: DELETE /api/users/:id — delete another user's account

- **Priority**: P3
- **Type**: Integration Test
- **Size**: S
- **Status**: [ ] Todo
- **Target**: `src/routes/users.ts` -> ownership check
- **Preconditions**: Two users exist; JWT for user A
- **Input**: Bearer token for user A, `:id` = user B's ID
- **Expected Output**: HTTP 403
- **Test File**: `src/routes/users.test.ts`
- **Notes**: Authorization (ownership check) distinct from authentication.

---

## Middleware

### TC-011: Rate limiting — exceed threshold

- **Priority**: P1
- **Type**: Integration Test
- **Size**: L
- **Status**: [ ] Todo
- **Target**: `src/middleware/rateLimit.ts`
- **Preconditions**: KV binding available (miniflare)
- **Input**: 11 requests from the same IP within 60 seconds (limit: 10)
- **Expected Output**: First 10 → HTTP 200; 11th → HTTP 429
- **Test File**: `src/middleware/rateLimit.test.ts`
- **Notes**: Use fake timers in Vitest to control clock. KV TTL is set to 60s.

### TC-012: CORS — preflight OPTIONS request

- **Priority**: P2
- **Type**: Integration Test
- **Size**: S
- **Status**: [ ] Todo
- **Target**: `src/index.ts` -> Hono `cors()` middleware
- **Preconditions**: CORS configured for `https://app.example.com`
- **Input**: `OPTIONS /api/users` with `Origin: https://app.example.com`
- **Expected Output**: HTTP 204, `Access-Control-Allow-Origin: https://app.example.com`
- **Test File**: `src/index.test.ts`
- **Notes**: Verify disallowed origins receive no CORS headers.
```
