# Consistency Matrix — Cross-File Source of Truth

A single table to resolve conflicts when two files disagree. Consult this during Phase 5 (Consistency Check) and any time drift detection surfaces the same fact in multiple places.

---

## Resolution rule

When two files disagree, edit the **downstream** file to match the **upstream** value. Upstream is defined per fact below — it is never "whichever was updated more recently". Recency is not a substitute for authority.

---

## Fact-by-fact table

Upstream appears leftmost; each column to the right is downstream of the one before it.

| Fact | Upstream 1 (truth) | Upstream 2 | Downstream |
|---|---|---|---|
| Runtime version (Node/Bun/Deno) | `.tool-versions` / `mise.toml` / `.node-version` | `package.json` `engines` | `docs/tech.md` → `AGENTS.md` → `README.md` |
| Library version | Lock file (`pnpm-lock.yaml`, `Cargo.lock`) | `package.json` dependencies | `docs/tech.md` → `AGENTS.md` |
| Dev / build / test commands | `package.json` scripts / `Makefile` | — | `AGENTS.md` Key Commands → `README.md` Quick Start |
| Env-var names | `.env.example` / `.dev.vars.example` | `wrangler.*` `[vars]` | `docs/tech.md` → `AGENTS.md` → `README.md` |
| Binding names (D1, KV, R2, DO) | `wrangler.*` | — | `docs/design.md` → `AGENTS.md` |
| Directory layout | Actual filesystem (`ls`, `find`) | — | `docs/directory.md` → `AGENTS.md` |
| Routing / middleware composition | Entry point source (`src/index.ts`) | — | `docs/design.md` |
| Deployment command | CI workflow (`.github/workflows/deploy.yml`) | `package.json` scripts | `AGENTS.md` Deploy → `README.md` |
| Test framework & coverage target | `vitest.config.*` + CI config | — | `docs/test.md` → `AGENTS.md` TDD Rules |
| Task status | `git log` + merged PRs + issue tracker | — | `docs/tasks.md` |
| Known bugs & workarounds | Open issues, `TODO:` / `FIXME:` comments | — | `docs/problems.md` → `AGENTS.md` Prohibitions |
| Project one-liner | `docs/requirements.md` Project Overview | — | `AGENTS.md` Project Overview → `README.md` intro |

---

## Common conflict shapes

### Three-way disagreement

Three files state three different values. Do not average; do not pick the middle one. Resolve top-down: set Upstream 1 correctly first, then propagate.

### "Upstream is wrong"

If the upstream source itself looks wrong (e.g., `package.json` pins an ancient version that no one actually uses), **stop and ask the user**. Documentation drift often surfaces real code-side bugs — do not silently paper over them by aligning docs to a broken source.

### Orphan fact

A fact appears only in a downstream file with no upstream anchor (e.g., `AGENTS.md` lists a command no `package.json` script defines). Two possible fixes:

1. **Promote**: add a corresponding script to `package.json`, then keep the docs reference.
2. **Remove**: if the command is no longer valid, delete it from docs.

Never leave an orphan fact in place — it will drift again.

---

## Relationship to doc-fields.md

- [doc-fields.md](doc-fields.md) answers: *"When I'm filling in field X of file Y, where does the value come from?"*
- This file answers: *"When files Y1 and Y2 disagree on the same fact, which one wins?"*

The two are deliberately narrow so each stays short. Consult the right one based on the question you have.
