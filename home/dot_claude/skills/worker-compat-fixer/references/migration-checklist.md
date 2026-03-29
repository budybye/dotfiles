# Worker Compatibility Migration Checklist

Use this checklist when migrating a Node.js application or library to Cloudflare Workers (workerd).
Work through each phase in order; phases 1–3 are always required. Phases 4–5 are optional.

---

## Phase 1: Configuration

```
[ ] wrangler.jsonc exists and has a valid `compatibility_date` (≥ 2024-09-23)
[ ] `"nodejs_compat"` is listed in `compatibility_flags`
[ ] `main` points to the correct entry file (TypeScript or bundled JS)
[ ] D1 / KV / R2 / DO bindings are declared (if used)
[ ] `.dev.vars` exists and has all required secrets for local dev
```

`wrangler.jsonc` minimal baseline:

```jsonc
{
  "name": "my-worker",
  "main": "src/index.ts",
  "compatibility_date": "2025-03-01",
  "compatibility_flags": ["nodejs_compat"]
}
```

---

## Phase 2: Build-time Errors

Run `wrangler build` (or `wrangler dev`) and fix each error in order:

```
[ ] Resolve "Could not resolve 'node:xxx'" — add `node:` prefix or replace with Web Standard
[ ] Resolve "Cannot use native addon" — remove .node file dependencies
[ ] Resolve "Dynamic require()" — replace with static ES import or `await import()`
[ ] Bundle size < 1 MB (free tier) / < 10 MB (paid) — use `wrangler build --bundle-report`
```

Common `node:` prefix fixes:

| Original          | Fixed                         |
|-------------------|-------------------------------|
| `import crypto`   | `import crypto from "node:crypto"` |
| `import fs`       | ❌ Not available — use R2 / KV |
| `import path`     | `import path from "node:path"` |
| `require('buffer')` | `import { Buffer } from "node:buffer"` |

---

## Phase 3: Runtime Errors

Test with `wrangler dev` or Vitest + `@cloudflare/vitest-pool-workers`:

```
[ ] No "X is not a function" — verify API is available in workerd (see compat-matrix.md)
[ ] No CPU limit exceeded warnings — replace synchronous heavy loops with streaming/chunking
[ ] No "Cannot perform I/O on behalf of a different request" — fix cross-request async leaks
[ ] No uncaught promise rejections — wrap all `await` calls in try/catch or `.catch()`
```

---

## Phase 4: Library Replacements

Replace Node.js-specific libraries with Workers-compatible alternatives:

```
[ ] axios / node-fetch  → native fetch()
[ ] bcrypt (native)     → bcryptjs (pure JS)
[ ] jsonwebtoken        → jose (Web Crypto based)
[ ] multer              → Request.formData()
[ ] express             → Hono
[ ] morgan / winston    → Workers-native logging (console + structured JSON)
[ ] uuid (v4)           → crypto.randomUUID()
```

For full alternatives list: [alternatives.md](alternatives.md)

---

## Phase 5: Web Crypto Rewrites

If `node:crypto` is used beyond `randomUUID` / `randomBytes`:

```
[ ] HMAC signing       — replaced with Web Crypto (see web-crypto-cookbook.md)
[ ] AES encryption     — replaced with SubtleCrypto.encrypt / decrypt
[ ] SHA hashing        — replaced with SubtleCrypto.digest
[ ] RSA sign/verify    — replaced with SubtleCrypto.sign / verify
[ ] Key generation     — replaced with SubtleCrypto.generateKey
```

---

## Phase 6: Testing

```
[ ] vitest.config.ts uses `defineWorkersConfig` from `@cloudflare/vitest-pool-workers/config`
[ ] `wrangler` option in poolOptions points to wrangler.jsonc
[ ] All tests run in workerd pool (not Node.js pool)
[ ] D1 / KV / R2 bindings are available via `env` from `cloudflare:test`
[ ] `wrangler deploy --dry-run` passes with no errors
```

---

## Quick Diagnosis Cheat Sheet

| Symptom | Likely Cause | Fix |
|---|---|---|
| `Cannot resolve 'crypto'` | Missing `node:` prefix | `import crypto from "node:crypto"` |
| `X is not a function` | Unimplemented stub | Check compat-matrix.md; replace or add flag |
| CPU limit exceeded | Sync blocking code | Convert to async / streaming |
| `fetch is not defined` | Old compatibility_date | Update date to 2022-03-21+ |
| `require is not defined` | CommonJS in ES module context | Convert to `import` or use bundle step |
| Bundle too large | Heavy dependency included | Use esbuild tree-shaking; replace with lighter lib |
| `I/O on behalf of a different request` | Shared state across requests | Move to request-scoped variables |
