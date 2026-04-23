# Doc Fields Reference

A table of what each documentation file should contain and where the authoritative value comes from. Consulted when deciding "which side is the source of truth" during an update.

> Full templates for each file live in [make-docs/references/templates.md](../../make-docs/references/templates.md).

---

## AGENTS.md

| Field | Source of truth |
|---|---|
| Tech stack (language, framework, runtime) | `package.json`, `wrangler.{toml,jsonc}`, `Cargo.toml`, `go.mod`, `pyproject.toml` |
| Environment variables | `wrangler.*` bindings, `.env.example`, `.dev.vars.example` |
| Key commands (`dev`, `deploy`, `test`) | `package.json` scripts, `Makefile`, `justfile` |
| Constraints & gotchas | `docs/problems.md`, inline code comments |
| Directory overview | `docs/directory.md` |

---

## docs/tech.md

| Field | Source of truth |
|---|---|
| Library versions | `package.json` + lock file (`pnpm-lock.yaml`, `package-lock.json`), `Cargo.lock` |
| Runtime versions (Node/Deno/Bun) | `.node-version`, `.tool-versions`, `mise.toml`, `rust-toolchain.toml` |
| Build tools | `package.json` devDependencies, `wrangler.*`, `vite.config.*`, `tsup.config.*` |
| Test framework | `package.json` + `vitest.config.*` / `jest.config.*` |

---

## docs/design.md

| Field | Source of truth |
|---|---|
| Routing structure | `src/` entry point (e.g. `src/index.ts`), app definition files |
| Binding names | `wrangler.*` → `[d1_databases]`, `[kv_namespaces]`, `[r2_buckets]`, `[durable_objects]` |
| Environment-variable references | `wrangler.*` `[vars]`, `.env.example` |
| Architecture diagram commentary | Cross-check against actual module structure |

---

## docs/directory.md

| Field | Source of truth |
|---|---|
| File tree | Actual directory layout (`ls`, `find`, `tree`) |
| Per-file/-directory role | Code contents, `index.ts` exports, module docstrings |

---

## docs/tasks.md

| Field | Source of truth |
|---|---|
| TODO / In-progress tasks | Inline `TODO:` comments, issue tracker |
| Completed tasks | `git log`, merged PR history |

---

## docs/problems.md

| Field | Source of truth |
|---|---|
| Known bugs & limitations | Code comments, issues, error logs |
| Environment gotchas | Failing-test logs, CI configuration |

---

## docs/requirements.md

| Field | Source of truth |
|---|---|
| Functional requirements | User interviews, specs, issues |
| Non-functional requirements | Infra configuration, SLA docs, `wrangler.*` limits |

---

## docs/test.md

| Field | Source of truth |
|---|---|
| Testing strategy | `vitest.config.*`, test file layout |
| Coverage targets | CI configuration, `.github/workflows/` |
| Test commands | `package.json` scripts |

---

## README.md

| Field | Source of truth |
|---|---|
| Project overview | `docs/requirements.md` |
| Install / quick-start | `package.json` scripts + `AGENTS.md` Key Commands |
| Environment variables | `.env.example`, `wrangler.*` |
| Badges (CI / coverage) | `.github/workflows/`, coverage service config |
