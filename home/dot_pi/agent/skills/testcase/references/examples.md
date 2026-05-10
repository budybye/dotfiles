# Filled Example — Hono + Cloudflare Workers

A complete test-case list for a Hono REST API project. Use as a reference when producing `tests/testlist.md` for similar projects.

> For the generic templates, see [formats.md](formats.md). For classification and priority rules, see [methodology.md](methodology.md).

---

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
- **Notes**: Verify JWT structure (header.payload.signature). See TC-003 for protected-route usage.

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
- **Notes**: Same error as TC-002 (no user enumeration).

### TC-004: POST /api/auth/login — malformed body

- **Priority**: P1
- **Type**: Unit Test
- **Size**: S
- **Status**: [ ] Todo
- **Target**: `src/routes/auth.ts` -> Zod validation
- **Preconditions**: None
- **Input**: `{ email: "not-an-email" }`
- **Expected Output**: HTTP 400, Zod validation errors
- **Test File**: `src/routes/auth.test.ts`
- **Notes**: Validated by `zValidator` before handler runs.

---

## Users (CRUD)

### TC-005: POST /api/users — create

- **Priority**: P0
- **Type**: Integration Test
- **Size**: M
- **Status**: [ ] Todo
- **Target**: `src/routes/users.ts` -> `POST /api/users`
- **Preconditions**: No user with `newuser@example.com` in D1
- **Input**: `{ name: "Alice", email: "newuser@example.com", password: "secure123" }`
- **Expected Output**: HTTP 201, body `{ id: "<uuid>", name: "Alice", email: "newuser@example.com" }`
- **Test File**: `src/routes/users.test.ts`
- **Notes**: Password must NOT appear in response. UUID: `hex(randomblob(16))`.

### TC-006: POST /api/users — duplicate email

- **Priority**: P0
- **Type**: Integration Test
- **Size**: S
- **Status**: [ ] Todo
- **Target**: `src/routes/users.ts` -> `POST /api/users`
- **Preconditions**: User with `test@example.com` exists
- **Input**: `{ name: "Bob", email: "test@example.com", password: "secure123" }`
- **Expected Output**: HTTP 409, `{ error: "Email already in use" }`
- **Test File**: `src/routes/users.test.ts`
- **Notes**: D1 UNIQUE constraint on email column.

### TC-007: GET /api/users/:id — fetch own profile

- **Priority**: P1
- **Type**: Integration Test
- **Size**: M
- **Status**: [ ] Todo
- **Target**: `src/routes/users.ts` -> `GET /api/users/:id`
- **Preconditions**: User exists; valid JWT for that user
- **Input**: Bearer token, `:id` = own user ID
- **Expected Output**: HTTP 200, `{ id, name, email, created }`
- **Test File**: `src/routes/users.test.ts`
- **Notes**: Uses `testClient` from Hono. → TC-008.

### TC-008: GET /api/users/:id — no token

- **Priority**: P1
- **Type**: Integration Test
- **Size**: S
- **Status**: [ ] Todo
- **Target**: `src/middleware/auth.ts` -> Bearer check
- **Preconditions**: None
- **Input**: No Authorization header
- **Expected Output**: HTTP 401
- **Test File**: `src/routes/users.test.ts`
- **Notes**: Middleware short-circuits before handler. → TC-007.

### TC-009: DELETE /api/users/:id — delete own

- **Priority**: P2
- **Type**: Integration Test
- **Size**: M
- **Status**: [ ] Todo
- **Target**: `src/routes/users.ts` -> `DELETE /api/users/:id`
- **Preconditions**: User exists; valid JWT
- **Input**: Bearer token, `:id` = own ID
- **Expected Output**: HTTP 204 No Content
- **Test File**: `src/routes/users.test.ts`
- **Notes**: Row removed from D1. Next GET → 404.

### TC-010: DELETE /api/users/:id — delete another

- **Priority**: P3
- **Type**: Integration Test
- **Size**: S
- **Status**: [ ] Todo
- **Target**: `src/routes/users.ts` -> ownership check
- **Preconditions**: Two users; JWT for user A
- **Input**: Bearer A, `:id` = user B's ID
- **Expected Output**: HTTP 403
- **Test File**: `src/routes/users.test.ts`
- **Notes**: Authorization (ownership) is distinct from authentication.

---

## Middleware

### TC-011: Rate limiting — threshold exceeded

- **Priority**: P1
- **Type**: Integration Test
- **Size**: L
- **Status**: [ ] Todo
- **Target**: `src/middleware/rateLimit.ts`
- **Preconditions**: KV binding available (miniflare)
- **Input**: 11 requests from the same IP within 60 s (limit: 10)
- **Expected Output**: First 10 → HTTP 200; 11th → HTTP 429
- **Test File**: `src/middleware/rateLimit.test.ts`
- **Notes**: Use Vitest fake timers. KV TTL = 60 s.

### TC-012: CORS — preflight OPTIONS

- **Priority**: P2
- **Type**: Integration Test
- **Size**: S
- **Status**: [ ] Todo
- **Target**: `src/index.ts` -> Hono `cors()` middleware
- **Preconditions**: CORS configured for `https://app.example.com`
- **Input**: `OPTIONS /api/users` with `Origin: https://app.example.com`
- **Expected Output**: HTTP 204, `Access-Control-Allow-Origin: https://app.example.com`
- **Test File**: `src/index.test.ts`
- **Notes**: Disallowed origins must receive no CORS headers.
```

---

## How to use this example

- Adapt category names (**Auth**, **Users (CRUD)**, **Middleware**) to your project's module boundaries.
- Keep TC-IDs contiguous across categories — do not restart numbering per module.
- When in doubt about priority, use `methodology.md` P0–P3 definitions, not gut feel.
