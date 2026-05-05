# /repo-research Output Templates

Templates for recording findings from repository research and documentation lookups.

---

## Research Memo Template (`docs/research/<topic>.md`)

Use this when investigating an external library or codebase. Save as `docs/research/<YYYY-MM-DD>-<topic>.md`.

```markdown
# Research: [Library / Topic Name]

> Date: YYYY-MM-DD
> Researcher: [Name / AI agent]
> Source: [WebSearch | ghq clone | both]
> Repo: [github.com/owner/repo] (if cloned)

---

## Summary

[2–3 sentence overview of what was found. Lead with the most actionable insight.]

---

## Key Findings

### How to Use

[Minimal usage example — the most common pattern]

```ts
// example code
```

### Internal Architecture (if source was read)

[Brief description of module structure, key files, main abstractions]

- `src/core/xxx.ts` — [role]
- `src/middleware/yyy.ts` — [role]

### API / Interface

| Item | Type | Description |
|---|---|---|
| `methodName(arg)` | `(arg: T) => Promise<R>` | [what it does] |
| `OptionKey` | `string \| number` | [what it controls] |

---

## Decision

[What will be used from this research? What was rejected and why?]

- ✅ Use `X` for [reason]
- ❌ Avoid `Y` because [reason]
- ⚠️ `Z` works but note [caveat]

---

## References

- [Official docs](https://...)
- [Source file read]($(ghq root)/github.com/owner/repo/src/xxx.ts)
- Search query used: `"[exact query string]"`
```

---

## Quick Findings Note (inline, no file needed)

For small lookups that don't need a saved file, structure findings as:

```
Library: [name@version]
Source: WebSearch / ghq

Finding:
- [Key point 1]
- [Key point 2]
- [Gotcha or caveat]

Recommendation: [one sentence]
```

---

## ghq Session Log Template

When multiple repos are explored in one session, log what was cloned and why:

```markdown
## ghq Session — YYYY-MM-DD

| Repo | Reason | Key Files Read | Outcome |
|---|---|---|---|
| `github.com/honojs/hono` | Understand middleware interface | `src/middleware/bearer-auth.ts` | Used pattern directly |
| `github.com/cloudflare/workers-sdk` | Investigate D1 binding types | `packages/wrangler/src/d1/types.ts` | Types copied to project |
```

---

## WebSearch Query Log

Track queries to avoid repeating and to build a reference for future sessions:

```markdown
## Search Queries — YYYY-MM-DD

| Query | Top result | Useful? | Notes |
|---|---|---|---|
| `"bearerAuth" middleware site:hono.dev` | `hono.dev/middleware/builtin/bearer-auth` | ✅ | Found `verifyToken` callback |
| `"D1Database" prepared statement site:developers.cloudflare.com` | Workers D1 docs | ✅ | `.bind()` + `.run()` pattern |
| `vitest "fake timers" workerd` | mixed | ⚠️ | Generic docs; workerd-specific behavior not covered |
```
