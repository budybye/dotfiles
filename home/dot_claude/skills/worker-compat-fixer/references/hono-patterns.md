# Hono Web API Patterns for Cloudflare Workers

Practical, copy-paste patterns for building Web APIs with Hono on Cloudflare Workers.

---

## 1. Project Setup

### `wrangler.jsonc`

```jsonc
{
  "name": "my-api",
  "main": "src/index.ts",
  "compatibility_date": "2026-03-26",
  "compatibility_flags": ["nodejs_compat"],
  "d1_databases": [
    { "binding": "DB", "database_name": "my-db", "database_id": "<id>" }
  ],
  "kv_namespaces": [
    { "binding": "KV", "id": "<id>" }
  ]
}
```

### `src/index.ts` (Entry Point)

```ts
import { Hono } from "hono"
import { usersRoute } from "./routes/users"

type Bindings = {
  DB: D1Database
  KV: KVNamespace
}

const app = new Hono<{ Bindings: Bindings }>()

app.route("/api/users", usersRoute)

export default app
```

---

## 2. REST API: CRUD Routes

```ts
// src/routes/users.ts
import { Hono } from "hono"
import { zValidator } from "@hono/zod-validator"
import { z } from "zod"

type Bindings = { DB: D1Database }

export const usersRoute = new Hono<{ Bindings: Bindings }>()

const createUserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
})

// GET /api/users
usersRoute.get("/", async (c) => {
  const { results } = await c.env.DB.prepare("SELECT * FROM users").all()
  return c.json(results)
})

// GET /api/users/:id
usersRoute.get("/:id", async (c) => {
  const id = c.req.param("id")
  const user = await c.env.DB.prepare("SELECT * FROM users WHERE id = ?")
    .bind(id)
    .first()
  if (!user) return c.json({ error: "Not Found" }, 404)
  return c.json(user)
})

// POST /api/users
usersRoute.post("/", zValidator("json", createUserSchema), async (c) => {
  const { name, email } = c.req.valid("json")
  const result = await c.env.DB.prepare(
    "INSERT INTO users (name, email) VALUES (?, ?) RETURNING *"
  )
    .bind(name, email)
    .first()
  return c.json(result, 201)
})

// DELETE /api/users/:id
usersRoute.delete("/:id", async (c) => {
  const id = c.req.param("id")
  await c.env.DB.prepare("DELETE FROM users WHERE id = ?").bind(id).run()
  return c.body(null, 204)
})
```

---

## 3. Middleware Patterns

### Bearer Auth

```ts
import { bearerAuth } from "hono/bearer-auth"

app.use("/api/*", bearerAuth({ token: c.env.API_TOKEN }))
// Note: for dynamic token from env, use a factory:
app.use("/api/*", (c, next) => bearerAuth({ token: c.env.API_TOKEN })(c, next))
```

### CORS

```ts
import { cors } from "hono/cors"

app.use(
  "/api/*",
  cors({
    origin: ["https://example.com"],
    allowMethods: ["GET", "POST", "PUT", "DELETE"],
    allowHeaders: ["Content-Type", "Authorization"],
  })
)
```

### Global Error Handler

```ts
import { HTTPException } from "hono/http-exception"

app.onError((err, c) => {
  if (err instanceof HTTPException) {
    return err.getResponse()
  }
  console.error(err)
  return c.json({ error: "Internal Server Error" }, 500)
})

app.notFound((c) => c.json({ error: "Not Found" }, 404))
```

### Custom Middleware (Request ID + Logging)

```ts
import { createMiddleware } from "hono/factory"

export const requestLogger = createMiddleware(async (c, next) => {
  const requestId = crypto.randomUUID()
  c.set("requestId", requestId)
  const start = Date.now()
  await next()
  console.log(`[${requestId}] ${c.req.method} ${c.req.path} ${c.res.status} ${Date.now() - start}ms`)
})
```

---

## 4. Hono + KV (Session / Cache)

```ts
// Store session data
app.post("/session", async (c) => {
  const sessionId = crypto.randomUUID()
  const body = await c.req.json()
  await c.env.KV.put(`session:${sessionId}`, JSON.stringify(body), {
    expirationTtl: 3600, // 1 hour
  })
  return c.json({ sessionId })
})

// Retrieve session data
app.get("/session/:id", async (c) => {
  const id = c.req.param("id")
  const raw = await c.env.KV.get(`session:${id}`)
  if (!raw) return c.json({ error: "Session not found" }, 404)
  return c.json(JSON.parse(raw))
})
```

---

## 5. Type-Safe RPC with Hono Client

Define the API type on the server, consume it type-safely on the client (e.g., in a frontend or another Worker).

```ts
// server: src/routes/items.ts
import { Hono } from "hono"
import { zValidator } from "@hono/zod-validator"
import { z } from "zod"

const itemSchema = z.object({ name: z.string(), price: z.number() })

export const itemsRoute = new Hono()
  .get("/", (c) => c.json([{ id: 1, name: "Widget", price: 9.99 }]))
  .post("/", zValidator("json", itemSchema), async (c) => {
    const data = c.req.valid("json")
    return c.json({ id: 2, ...data }, 201)
  })

export type ItemsRouteType = typeof itemsRoute

// client: src/client.ts
import { hc } from "hono/client"
import type { ItemsRouteType } from "./routes/items"

const client = hc<ItemsRouteType>("https://my-api.example.com/api/items")

// Fully type-safe
const res = await client.$get()
const items = await res.json() // inferred type
```

---

## 6. Streaming Response

```ts
import { stream, streamText } from "hono/streaming"

// Stream raw data
app.get("/stream", (c) =>
  stream(c, async (s) => {
    for (let i = 0; i < 5; i++) {
      await s.write(`chunk ${i}\n`)
      await s.sleep(100)
    }
  })
)

// Proxy an upstream stream (e.g., AI completion)
app.get("/proxy-stream", async (c) => {
  const upstream = await fetch("https://api.example.com/stream")
  return streamText(c, async (s) => {
    const reader = upstream.body!.getReader()
    while (true) {
      const { done, value } = await reader.read()
      if (done) break
      await s.write(new TextDecoder().decode(value))
    }
  })
})
```

---

## 7. Testing with Vitest + Workers Pool

### `vitest.config.ts`

```ts
import { defineWorkersConfig } from "@cloudflare/vitest-pool-workers/config"

export default defineWorkersConfig({
  test: {
    poolOptions: {
      workers: {
        wrangler: { configPath: "./wrangler.jsonc" },
      },
    },
  },
})
```

### Test File (`src/routes/users.test.ts`)

```ts
import { describe, it, expect, beforeEach } from "vitest"
import { env } from "cloudflare:test"
import app from "../index"

// Use testClient for type-safe testing without a live server
import { testClient } from "hono/testing"

// Option A: testClient (recommended for unit tests)
describe("Users API — testClient", () => {
  const client = testClient(app)

  it("GET /api/users returns an array", async () => {
    const res = await client.api.users.$get()
    expect(res.status).toBe(200)
    const body = await res.json()
    expect(Array.isArray(body)).toBe(true)
  })

  it("POST /api/users creates a user", async () => {
    const res = await client.api.users.$post({
      json: { name: "Alice", email: "alice@example.com" },
    })
    expect(res.status).toBe(201)
    const user = await res.json()
    expect(user.name).toBe("Alice")
  })

  it("POST /api/users rejects invalid payload", async () => {
    const res = await client.api.users.$post({
      json: { name: "", email: "not-an-email" },
    })
    expect(res.status).toBe(400)
  })
})

// Option B: raw fetch against SELF (integration test)
describe("Users API — fetch SELF", () => {
  it("GET /api/users/999 returns 404", async () => {
    const res = await SELF.fetch("http://localhost/api/users/999")
    expect(res.status).toBe(404)
  })
})
```

---

## 8. Hono Context Variables (Type-Safe)

```ts
import { Hono, createFactory } from "hono"

type Variables = {
  userId: string
  requestId: string
}

const app = new Hono<{ Variables: Variables }>()

app.use("*", async (c, next) => {
  c.set("requestId", crypto.randomUUID())
  await next()
})

app.get("/me", async (c) => {
  const requestId = c.get("requestId") // string — fully typed
  return c.json({ requestId })
})
```
