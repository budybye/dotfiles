---
name: worker-compat-fixer
description: A skill for diagnosing and resolving Node.js incompatibilities when deploying to Cloudflare Workers (workerd). Provides a phase-by-phase migration checklist, API compatibility matrix, Web Crypto recipes, and Hono-based code patterns. Prioritizes native Web Standard APIs over polyfills for minimal bundle size. [Triggers: /worker-compat-fixer, wrangler.jsonc, nodejs_compat, workerd, compatibility, fetch, streams, crypto, Hono, polyfill, shim, migrate to workers, workers build error, not a function in workers]
---

# /worker-compat-fixer — Workers Node.js Compatibility Skill

Diagnose Node.js incompatibilities in the Cloudflare Workers (workerd) environment and provide a consistent workflow from planning to implementation and testing.

## Quick Reference

| Task                                     | Guide                                                                  |
| ---------------------------------------- | ---------------------------------------------------------------------- |
| Node.js API Compatibility Matrix         | [references/compat-matrix.md](references/compat-matrix.md)             |
| Recommended Alternatives (Web Standards) | [references/alternatives.md](references/alternatives.md)               |
| Common Shim Patterns                     | [references/shim-patterns.md](references/shim-patterns.md)             |
| node:crypto to Web Crypto Recipes        | [references/web-crypto-cookbook.md](references/web-crypto-cookbook.md) |
| Hono Web API Patterns & Testing          | [references/hono-patterns.md](references/hono-patterns.md)             |
| Migration Checklist (phase-by-phase)     | [references/migration-checklist.md](references/migration-checklist.md) |

---

## Agent Guidelines

- **Standard-First**: Prioritize native Web Standard APIs (e.g., `fetch`, `crypto.subtle`, `TransformStream`) over Node.js polyfills to minimize bundle size and maximize performance.
- **Hono Preferred**: When suggesting a framework or middleware, use Hono as the standard for Workers-native development.
- **Verify Config**: Always check `wrangler.jsonc` for `compatibility_flags` and `compatibility_date` before proposing code changes.
- **Sync is Evil**: Warn the user about synchronous I/O or heavy operations; suggest asynchronous alternatives immediately.

---

## Workflow

```txt
Phase 1: Diagnosis (Check build/runtime errors and wrangler config)
  ↓
Phase 2: Strategy (Choose between Native APIs, Hono, or Shims)
  ↓
Phase 3: Implementation (Apply 'node:' prefix, replace libs, add shims)
  ↓
Phase 4: Verification (Run Vitest in workerd pool or 'wrangler dev')
```

### Phase 1: Diagnosis

Identify the issue based on error patterns:

- **Build-time**: Missing `nodejs_compat` flag or missing `node:` prefix.
- **Runtime**: "xxx is not a function" (unimplemented stub) or CPU limit exceeded (sync logic).
- **Structural**: Dependency on `child_process`, `worker_threads`, or native addons (.node).

### Phase 2: Choosing a Strategy

1. **Configuration**: Ensure `wrangler.jsonc` has `nodejs_compat` and a modern `compatibility_date`.
2. **Framework**: Use Hono for routing and standard-compliant middleware.
3. **Library Replacement**: Replace legacy libs (e.g., `axios` -> `fetch`, `bcrypt` -> `bcryptjs`).
4. **Web Standard Rewrite**: Convert `node:crypto` logic to `Web Crypto API`.

---

## Technical Stack Example (Hono + Web Standards)

```ts
import { Hono } from "hono";

const app = new Hono();

app.get("/api/stream", async (c) => {
	// Use native Fetch & Web Streams
	const response = await fetch("https://api.example.com");
	const { readable, writable } = new TransformStream();
	response.body?.pipeTo(writable);
	return c.body(readable);
});

export default app;
```

## Maintenance & Testing

- Use `@cloudflare/vitest-pool-workers` for accurate runtime testing.
- Check bundle size with `wrangler build --bundle-report`.
