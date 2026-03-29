# /tdd-cycle Test File Templates

Boilerplate and structural patterns for test files in a Hono + Cloudflare Workers project.
Copy these as a starting point for each new test file.

---

## Vitest Setup (`vitest.config.ts`)

```ts
import { defineWorkersConfig } from "@cloudflare/vitest-pool-workers/config";

export default defineWorkersConfig({
  test: {
    poolOptions: {
      workers: {
        wrangler: { configPath: "./wrangler.jsonc" },
      },
    },
  },
});
```

---

## Route Test Boilerplate (Hono + `testClient`)

Use `testClient` from `hono/testing` to call routes without a live server.
Bindings (D1, KV) are injected via `env` in the `fetch` call.

```ts
// src/routes/users.test.ts
import { describe, it, expect, beforeEach } from "vitest";
import {
  env,
  createExecutionContext,
  waitOnExecutionContext,
  SELF,
} from "cloudflare:test";
import { testClient } from "hono/testing";
import app from "../index"; // Hono instance

// ---- helpers ----

async function createUser(payload = { name: "Alice", email: "alice@example.com", password: "password123" }) {
  const client = testClient(app);
  return client.api.users.$post({ json: payload }, { headers: {} });
}

async function login(email = "alice@example.com", password = "password123") {
  const client = testClient(app);
  const res = await client.api.auth.login.$post({ json: { email, password } });
  const { token } = await res.json();
  return token as string;
}

// ---- test suites ----

describe("POST /api/users", () => {
  // TC-005
  it("creates a new user and returns 201", async () => {
    const client = testClient(app);
    const res = await client.api.users.$post({
      json: { name: "Alice", email: "alice@example.com", password: "password123" },
    });

    expect(res.status).toBe(201);
    const body = await res.json();
    expect(body).toMatchObject({ name: "Alice", email: "alice@example.com" });
    expect(body).not.toHaveProperty("pw_hash");
    expect(body.id).toMatch(/^[a-f0-9]{32}$/);
  });

  // TC-006
  it("returns 409 when email is already taken", async () => {
    await createUser();
    const client = testClient(app);
    const res = await client.api.users.$post({
      json: { name: "Bob", email: "alice@example.com", password: "other123" },
    });

    expect(res.status).toBe(409);
    const body = await res.json();
    expect(body).toMatchObject({ error: "Email already in use" });
  });
});

describe("GET /api/users/:id", () => {
  // TC-007
  it("returns the user profile with a valid token", async () => {
    const { id } = await (await createUser()).json();
    const token = await login();
    const client = testClient(app);

    const res = await client.api.users[":id"].$get(
      { param: { id } },
      { headers: { Authorization: `Bearer ${token}` } },
    );

    expect(res.status).toBe(200);
    const body = await res.json();
    expect(body).toMatchObject({ id, name: "Alice", email: "alice@example.com" });
  });

  // TC-008
  it("returns 401 when no token is provided", async () => {
    const { id } = await (await createUser()).json();
    const client = testClient(app);

    const res = await client.api.users[":id"].$get(
      { param: { id } },
      { headers: {} },
    );

    expect(res.status).toBe(401);
  });
});
```

---

## Middleware Test Boilerplate

```ts
// src/middleware/auth.test.ts
import { describe, it, expect } from "vitest";
import { testClient } from "hono/testing";
import app from "../index";

describe("Auth Middleware", () => {
  it("rejects requests without Authorization header", async () => {
    const client = testClient(app);
    const res = await client.api.users[":id"].$get(
      { param: { id: "any" } },
      { headers: {} },
    );
    expect(res.status).toBe(401);
  });

  it("rejects requests with malformed Bearer token", async () => {
    const client = testClient(app);
    const res = await client.api.users[":id"].$get(
      { param: { id: "any" } },
      { headers: { Authorization: "Bearer not.a.jwt" } },
    );
    expect(res.status).toBe(401);
  });
});
```

---

## D1 Seed Helper

Use this pattern to insert test rows into D1 before each test.

```ts
// tests/helpers/seed.ts
import { env } from "cloudflare:test";

export async function seedUser(override: Partial<{
  id: string;
  name: string;
  email: string;
  pw_hash: string;
}> = {}) {
  const row = {
    id: "00000000000000000000000000000001",
    name: "Test User",
    email: "test@example.com",
    pw_hash: "$2a$12$placeholder_hash",
    ...override,
  };
  await env.DB.prepare(
    "INSERT INTO users (id, name, email, pw_hash) VALUES (?, ?, ?, ?)"
  )
    .bind(row.id, row.name, row.email, row.pw_hash)
    .run();
  return row;
}

export async function clearUsers() {
  await env.DB.prepare("DELETE FROM users").run();
}
```

Usage in tests:

```ts
import { beforeEach } from "vitest";
import { seedUser, clearUsers } from "../helpers/seed";

beforeEach(async () => {
  await clearUsers();
  await seedUser();
});
```

---

## KV Mock Pattern

```ts
// No mocking needed — KV is available as env.KV in vitest-pool-workers
import { env } from "cloudflare:test";

it("reads from KV", async () => {
  await env.KV.put("session:abc", JSON.stringify({ userId: "u1" }), { expirationTtl: 3600 });
  const val = await env.KV.get("session:abc", "json");
  expect(val).toEqual({ userId: "u1" });
});
```

---

## Snapshot Pattern (for Error Responses)

```ts
it("returns RFC 7807 problem detail on 422", async () => {
  const res = await client.api.users.$post({ json: { email: "bad" } });
  expect(res.status).toBe(422);
  const body = await res.json();
  // Snapshot the full error shape on first run; review on changes
  expect(body).toMatchSnapshot();
});
```

---

## `describe` / `it` Naming Conventions

| Pattern | Example |
|---|---|
| `describe("<METHOD> <path>")` | `describe("POST /api/users")` |
| `it("<verb> <expected outcome>")` | `it("returns 201 with user object")` |
| Reference TC-XXX in comments | `// TC-005` above the `it` block |
| Group happy-path first, then edge cases | Happy → Invalid input → Auth errors → Server errors |
