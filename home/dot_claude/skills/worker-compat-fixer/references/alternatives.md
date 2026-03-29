# Recommended Alternatives for Cloudflare Workers

This guide provides a list of recommended alternatives to common Node.js libraries that are either incompatible with or suboptimal for the Cloudflare Workers (workerd) runtime. Prioritize **Web Standard APIs** and **Workers-native libraries** to ensure performance and compatibility.

## HTTP / Networking

| Original Library     | Workers-Native Alternative       | Reason                                  |
| -------------------- | -------------------------------- | --------------------------------------- |
| `node-fetch`         | Native `fetch()`                 | Built into the Workers runtime.         |
| `axios`              | Native `fetch()` or `undici`     | Avoids heavy polyfills and `node:http`. |
| `got` / `superagent` | Native `fetch()`                 | Fetch is the standard for serverless.   |
| `ws`                 | `WebSocketPair` + DO Hibernation | Native WebSocket support in Workers.    |
| `socket.io`          | Durable Objects + WebSocket API  | Better scaling with the Workers model.  |

## Auth / Cryptography

| Original Library  | Workers-Native Alternative           | Reason                                     |
| ----------------- | ------------------------------------ | ------------------------------------------ |
| `bcrypt` (native) | `bcryptjs`                           | Pure JS implementation; avoids C++ addons. |
| `argon2` (native) | Web Crypto PBKDF2 or `@noble/hashes` | Native addons are not supported.           |
| `jsonwebtoken`    | `jose`                               | Optimized for Web Crypto; no Node deps.    |
| `node-forge`      | Web Crypto API                       | Standardized, secure, and faster.          |
| `crypto-js`       | Web Crypto API                       | Use native hardware-accelerated APIs.      |
| `passport`        | `hono/auth` or custom middleware     | Designed for the Workers lifecycle.        |

## Database

| Original Library          | Workers-Native Alternative           | Reason                                      |
| ------------------------- | ------------------------------------ | ------------------------------------------- |
| `pg`                      | `postgres` (porsager) or Hyperdrive  | Better TCP handling and connection pooling. |
| `mysql2`                  | D1 or Hyperdrive                     | Native Workers storage or TCP proxy.        |
| `better-sqlite3` (native) | `cloudflare:d1`                      | Managed SQLite native to Cloudflare.        |
| `mongodb`                 | Atlas Data API or HTTP-based clients | Standard TCP drivers often fail in Workers. |
| `redis` / `ioredis`       | Upstash Redis (`@upstash/redis`)     | HTTP-based; avoids long-lived TCP issues.   |
| `prisma`                  | `drizzle-orm` + D1/Hyperdrive        | Drizzle is lightweight and Workers-native.  |

## Web Frameworks

| Original Library  | Workers-Native Alternative | Reason                                      |
| ----------------- | -------------------------- | ------------------------------------------- |
| `express` / `koa` | `hono`                     | Ultra-lightweight, native to Workers/ESM.   |
| `fastify`         | `itty-router` or `hono`    | Lower cold start times and smaller bundles. |

## Validation / Schema

| Original Library | Workers-Native Alternative | Reason                                   |
| ---------------- | -------------------------- | ---------------------------------------- |
| `joi` / `yup`    | `zod` or `valibot`         | Excellent TypeScript and tree-shaking.   |
| `ajv`            | `zod`                      | Simpler API for serverless environments. |

## Utilities & Logging

| Original Library | Workers-Native Alternative                     | Reason                                    |
| ---------------- | ---------------------------------------------- | ----------------------------------------- |
| `lodash`         | Native JS or `es-toolkit`                      | Drastically reduces bundle size.          |
| `moment`         | `Temporal` API (polyfilled) or `date-fns`      | Smaller, immutable, and modern.           |
| `uuid`           | `crypto.randomUUID()`                          | Built into the global `crypto` object.    |
| `dotenv`         | Wrangler Secrets / Environment Bindings        | Secrets are injected via `env` argument.  |
| `winston`        | `pino` (browser mode) or Workers Observability | Standard `console` is usually sufficient. |

## File Processing

| Original Library    | Workers-Native Alternative | Reason                                    |
| ------------------- | -------------------------- | ----------------------------------------- |
| `multer` / `busboy` | `Request.formData()`       | Standard Web API for multipart parsing.   |
| `sharp` (native)    | Cloudflare Images API      | Native image processing is not supported. |
| `pdf-lib`           | `pdf-lib` (ESM version)    | Ensure no Node.js `fs` dependencies.      |

## Essential Workers Libraries

| Library            | Purpose                           | Link                          |
| ------------------ | --------------------------------- | ----------------------------- |
| **Hono**           | Web framework for the Edges       | https://hono.dev              |
| **Drizzle ORM**    | Type-safe ORM for D1/Hyperdrive   | https://orm.drizzle.team      |
| **jose**           | JWT and JWK using Web Crypto      | https://github.com/panva/jose |
| **@upstash/redis** | HTTP-based Redis client           | https://upstash.com           |
| **zod**            | Schema declaration and validation | https://zod.dev               |
