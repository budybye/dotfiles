---
name: worker-compat-fixer
description: "A skill for diagnosing and resolving Node.js incompatibilities when deploying to Cloudflare Workers (workerd). Provides a phase-by-phase migration checklist, API compatibility matrix, Web Crypto recipes, and Hono-based code patterns. Prioritizes native Web Standard APIs over polyfills for minimal bundle size. [Triggers: /worker-compat-fixer, wrangler.jsonc, nodejs_compat, workerd, compatibility, fetch, streams, crypto, Hono, polyfill, shim, migrate to workers, workers build error, not a function in workers, Cannot resolve, is not a function]"
---

# /worker-compat-fixer — Workers Node.js Compatibility Skill

Diagnose Node.js incompatibilities in the Cloudflare Workers (workerd) environment and provide a consistent workflow from planning to implementation and testing.

## Common Issues This Skill Addresses

- **"Cannot resolve 'module'" errors** → Add `node:` prefix (e.g., `import crypto from "node:crypto"`)
- **"xxx is not a function" runtime errors** → Check compatibility matrix and enable proper flags
- **Dependency migration** → Replace Node.js libraries with Web Standard equivalents
- **Performance issues** → Convert sync operations to async, use Web Streams
- **Express/Koa migrations** → Use Hono framework patterns

## Before Asking for Help, Check These First

1. Your `wrangler.jsonc` has `"nodejs_compat"` in `compatibility_flags`
2. Your `wrangler.jsonc` has a recent `compatibility_date` (≥ 2024-09-23)
3. Node.js modules have `node:` prefix (e.g., `import fs from "node:fs"`)
4. You're using Web Standard APIs where possible (`fetch`, `crypto.subtle`, etc.)

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
  - **Quick Fix**: Add `node:` prefix (e.g., `import crypto from "node:crypto"`)
- **Runtime**: "xxx is not a function" (unimplemented stub) or CPU limit exceeded (sync logic).
  - **Quick Fix**: Check [compat-matrix.md](references/compat-matrix.md) for API support status
- **Structural**: Dependency on `child_process`, `worker_threads`, or native addons (.node).
  - **Quick Fix**: Use Workers-native alternatives (Durable Objects, Queues, R2)

### Phase 2: Choosing a Strategy

1. **Configuration**: Ensure `wrangler.jsonc` has `nodejs_compat` and a modern `compatibility_date`.
2. **Framework**: Use Hono for routing and standard-compliant middleware.
3. **Library Replacement**: Replace legacy libs (e.g., `axios` -> `fetch`, `bcrypt` -> `bcryptjs`).
4. **Web Standard Rewrite**: Convert `node:crypto` logic to `Web Crypto API`.

### Quick Solutions Reference

| Error Pattern | Solution | Code Example | Reference |
|---------------|----------|-------------|-----------|
| "Cannot resolve 'crypto'" | Add `node:` prefix | `import crypto from "node:crypto"` | [migration-checklist.md](references/migration-checklist.md) |
| "Cannot resolve 'fs'" | Add `node:` prefix | `import fs from "node:fs"` | [migration-checklist.md](references/migration-checklist.md) |
| "xxx is not a function" | Check API compatibility; may need flag or alternative | See [compat-matrix.md](references/compat-matrix.md) | [compat-matrix.md](references/compat-matrix.md) |
| "CPU limit exceeded" | Convert sync operations to async/streaming | Replace `readFileSync` with R2/KV `get()` | This document |
| Using `fs` module | Replace with R2 or KV storage bindings | `env.MY_BUCKET.get("file.txt")` | [alternatives.md](references/alternatives.md) |
| Using Express/Koa | Migrate to Hono framework | `import { Hono } from "hono"` | [hono-patterns.md](references/hono-patterns.md) |
| Using `bcrypt` | Replace with `bcryptjs` | `import bcrypt from "bcryptjs"` | [alternatives.md](references/alternatives.md) |
| Using `axios` | Replace with native `fetch` | `const res = await fetch(url)` | [alternatives.md](references/alternatives.md) |

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

## Troubleshooting Common Issues

### Configuration Problems

**Problem**: "Unknown binding type 'nodejs_compat'"
**Solution**: Verify your `wrangler.jsonc` has the correct format:
```jsonc
{
  "compatibility_date": "2025-03-01",
  "compatibility_flags": ["nodejs_compat"]
}
```

### Import Resolution Errors

**Problem**: "Cannot resolve 'buffer'"
**Solution**: Add the `node:` prefix:
```js
// ❌ This fails
import { Buffer } from 'buffer';

// ✅ This works
import { Buffer } from 'node:buffer';
```

### Runtime API Errors

**Problem**: "crypto.randomBytes is not a function"
**Solution**: Check [compat-matrix.md](references/compat-matrix.md) to verify API support. If supported, ensure `nodejs_compat` flag is enabled.

### Performance Issues

**Problem**: "CPU limit exceeded"
**Solution**: Convert synchronous operations to asynchronous:
```js
// ❌ Blocking operation
const data = fs.readFileSync('config.json');

// ✅ Non-blocking operation
const data = await env.CONFIG_BUCKET.get('config.json');
```

### Bundle Size Problems

**Problem**: Deployment fails due to large bundle size
**Solution**: 
1. Run `wrangler build --bundle-report` to identify large dependencies
2. Replace heavy Node.js libraries with Web Standard equivalents
3. Use dynamic imports for code splitting
