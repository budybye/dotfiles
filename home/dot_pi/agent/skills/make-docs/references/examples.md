# /make-docs Filled Examples

A complete, filled-in example for a Hono + Cloudflare Workers API project. Use this as a reference when generating documentation for similar projects.

---

## docs/requirements.md — Example

```markdown
# Requirements

## Project Overview

A lightweight REST API built with Hono on Cloudflare Workers, providing user management and authentication. Designed for edge deployment with sub-10ms cold starts and zero-server-maintenance operations.

## Functional Requirements

### Must Have

- [ ] User registration (POST /api/users)
- [ ] User authentication via JWT (POST /api/auth/login)
- [ ] Protected route middleware (Bearer token)
- [ ] User profile retrieval (GET /api/users/:id)
- [ ] Input validation with Zod

### Should Have

- [ ] Refresh token flow
- [ ] Rate limiting per IP using KV
- [ ] Structured error responses (RFC 7807)

### Could Have

- [ ] Email verification
- [ ] OAuth2 (GitHub) login

## Non-Functional Requirements

### Performance

- Cold start: < 10ms (Workers isolate model)
- P99 response time: < 50ms for DB-backed routes (D1)

### Security

- Passwords hashed with bcryptjs (cost factor 12)
- JWT signed with HMAC-SHA256 via Web Crypto API
- No secrets in source code — all via `wrangler secret`

### Scalability

- Stateless Workers — scales to 0 and to millions automatically
- D1 for persistent state, KV for session/cache

## Constraints

- Runtime: Cloudflare Workers (workerd) — no Node.js built-ins beyond `nodejs_compat`
- No native addons (.node files)
- Max bundle size: 1MB (Workers free tier limit)

## Glossary

| Term | Definition |
|---|---|
| Worker | A Cloudflare serverless function running on the V8 isolate model |
| D1 | Cloudflare's managed SQLite database |
| KV | Cloudflare's global key-value store |
| DO | Durable Object — stateful Workers for coordination |
```

---

## docs/design.md — Example

```markdown
# Design

## Architecture Overview

```
Client
  └─ HTTPS ──► Cloudflare Workers (Hono router)
                    ├─ Auth Middleware (JWT verify)
                    ├─ /api/users ──► D1 (SQLite)
                    └─ /api/auth  ──► KV (session cache)
```

## Module Structure

### `src/index.ts`
- **Role**: Entry point. Mounts sub-routers and global middleware.
- **Dependencies**: `hono`, `./routes/users`, `./routes/auth`
- **Public Interface**: `export default app` (Hono instance)

### `src/routes/users.ts`
- **Role**: CRUD for user resources.
- **Dependencies**: `hono`, `zod`, `./schemas/user`, `./lib/db`

### `src/middleware/auth.ts`
- **Role**: JWT validation. Extracts `userId` into context.
- **Dependencies**: `hono/jwt`, Web Crypto API

### `src/lib/db.ts`
- **Role**: Thin wrapper over D1 — typed query helpers.
- **Dependencies**: `cloudflare:workers` (D1Database type)

## Data Model

```sql
CREATE TABLE users (
  id      TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
  name    TEXT NOT NULL,
  email   TEXT NOT NULL UNIQUE,
  pw_hash TEXT NOT NULL,
  created INTEGER NOT NULL DEFAULT (unixepoch())
);
```

## API Design

| Method | Path | Description | Auth |
|---|---|---|---|
| POST | /api/auth/login | Issue JWT | No |
| POST | /api/users | Create user | No |
| GET | /api/users/:id | Get user | Yes |
| DELETE | /api/users/:id | Delete user | Yes |

## ADR-001: Hono over itty-router

- **Situation**: Need a routing layer with middleware support and TypeScript types.
- **Decision**: Use Hono v4.
- **Reason**: Native Workers support, `testClient` for testing, Zod validator middleware, typed context variables.
- **Outcome**: Reduced boilerplate; full type inference from route to test.
```

---

## docs/tech.md — Example

```markdown
# Technical Specifications

## Tech Stack

| Category | Technology | Version |
|---|---|---|
| Language | TypeScript | 5.x |
| Runtime | Cloudflare Workers (workerd) | latest |
| Framework | Hono | 4.x |
| Database | Cloudflare D1 (SQLite) | - |
| Cache / Session | Cloudflare KV | - |
| Validation | Zod | 3.x |
| Auth | jose (Web Crypto JWT) | 5.x |
| Testing | Vitest + @cloudflare/vitest-pool-workers | latest |

## Development Environment

### Required Tools

- Node.js 20+
- pnpm 9+
- Wrangler CLI 3+ (`pnpm add -g wrangler`)

### Setup

```bash
pnpm install
cp .dev.vars.example .dev.vars   # fill in JWT_SECRET
wrangler d1 execute my-db --local --file=schema.sql
wrangler dev
```

## Environment Variables

| Variable | Required | Description | How to obtain |
|---|---|---|---|
| `JWT_SECRET` | Yes | HMAC-SHA256 signing key (min 32 chars) | Generate: `openssl rand -hex 32` |
| `DB` | Yes (binding) | D1 database binding | Declared in wrangler.jsonc |
| `KV` | Yes (binding) | KV namespace binding | Declared in wrangler.jsonc |

## Key Configuration Files

### `wrangler.jsonc`

```jsonc
{
  "name": "my-api",
  "main": "src/index.ts",
  "compatibility_date": "2026-03-26",
  "compatibility_flags": ["nodejs_compat"],
  "d1_databases": [{ "binding": "DB", "database_name": "my-db", "database_id": "..." }],
  "kv_namespaces": [{ "binding": "KV", "id": "..." }]
}
```
```

---

## AGENTS.md — Example

```markdown
# AGENTS.md

## Project Overview

Hono REST API on Cloudflare Workers — user management with JWT auth, D1, and KV.

## Development Policy

### Coding Style

- Prettier (default config) + ESLint with `@typescript-eslint`
- Run `pnpm lint` before committing

### Commit Message Convention

Conventional Commits: `feat(scope): description`
See `.cursor/plans/` for detailed examples.

### Branching Strategy

GitHub Flow — short-lived feature branches from `main`.

### Version Control

jj (Jujutsu) in colocated mode (`.jj` + `.git` coexist).

## TDD Rules

- Write tests one at a time.
- Red → Green → Refactor — never skip Refactor.
- Test file lives next to the source: `src/routes/users.test.ts`.

## Directory Conventions

→ See `docs/directory.md`

## Environment Variables

→ See `docs/tech.md` for the full list.
Copy `.dev.vars.example` to `.dev.vars` and fill in values.

## Forbidden

- Do not commit `.dev.vars` or any file containing secrets.
- Do not use `node:child_process` or `node:worker_threads`.
- Do not use synchronous I/O (`*Sync` APIs).

## Deploy

```bash
wrangler deploy
```
```
