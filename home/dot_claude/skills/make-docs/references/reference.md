# /make-docs References Template

Template for `docs/references.md` — a curated list of external documentation, repositories, articles, and standards relevant to the project. Generated during Phase 2 alongside the other `/docs` files.

## Important Instructions

When generating `docs/references.md`:
1. ONLY include resources directly referenced by the project's tech stack or architecture decisions
2. Prefer official documentation over blog posts or tutorials
3. Link to specific versioned docs when possible (e.g., `v4` not `latest`)
4. Annotate each entry with WHY it matters (one-line note)
5. Keep the list short — quality over quantity. Aim for ≤ 20 entries

---

## docs/references.md Template

```markdown
# References

Curated list of external resources relevant to this project.

## Official Documentation

| Resource | URL | Note |
| -------- | --- | ---- |
| [Tech Name] Docs | https://... | Primary API reference |
| [Runtime/Platform] Docs | https://... | Deployment & config guide |

## Repositories & Source

| Repo | URL | Note |
| ---- | --- | ---- |
| [org/repo] | https://github.com/... | Core library source |

## Standards & Specifications

| Standard | URL | Note |
| -------- | --- | ---- |
| [RFC/Web STD] | https://... | Protocol or format spec |

## Articles & Guides

| Title | URL | Note |
| ----- | --- | ---- |
| [Article Title] | https://... | Why it's relevant |
```

---

## Filled Example (Hono + Cloudflare Workers)

```markdown
# References

Curated list of external resources relevant to this project.

## Official Documentation

| Resource | URL | Note |
| -------- | --- | ---- |
| Hono Docs | https://hono.dev/docs | Routing, middleware, helpers |
| Cloudflare Workers Docs | https://developers.cloudflare.com/workers/ | Runtime API & limits |
| Cloudflare D1 Docs | https://developers.cloudflare.com/d1/ | SQLite bindings & queries |
| Web Crypto API (MDN) | https://developer.mozilla.org/en-US/docs/Web/API/SubtleCrypto | JWT signing & hashing |

## Repositories & Source

| Repo | URL | Note |
| ---- | --- | ---- |
| honojs/hono | https://github.com/honojs/hono | Framework source & examples |
| cloudflare/workers-sdk | https://github.com/cloudflare/workers-sdk | Wrangler CLI & types |

## Standards & Specifications

| Standard | URL | Note |
| -------- | --- | ---- |
| RFC 7519 (JWT) | https://tools.ietf.org/html/rfc7519 | Token format spec |
| RFC 7807 (Problem Details) | https://tools.ietf.org/html/rfc7807 | Error response format |
| Web Streams API | https://streams.spec.whatwg.org/ | Used for streaming responses |

## Articles & Guides

| Title | URL | Note |
| ----- | --- | ---- |
| Hono on Workers Guide | https://hono.dev/docs/getting-started/cloudflare-workers | Setup walkthrough |
| D1 Migration Guide | https://developers.cloudflare.com/d1/89-migrations/ | Schema migration strategy |
```

---

## Generation Guidelines

When populating `docs/references.md`, extract entries from these sources:

1. **From `tech.md`** — every technology listed in the stack table should have at least its official documentation linked
2. **From `design.md`** — ADR entries that reference external decisions or specs should be linked
3. **From `requirements.md`** — any compliance, regulatory, or standard requirements should link to the relevant specification
4. **From the actual codebase** — imported libraries' repos and docs

### Prioritization

When the list grows beyond 20 entries, apply this priority order:
1. **Must include**: Official docs for every item in the tech stack
2. **Should include**: Standards and specs referenced by ADRs or requirements
3. **May include**: High-quality articles that cover non-obvious patterns used in the project