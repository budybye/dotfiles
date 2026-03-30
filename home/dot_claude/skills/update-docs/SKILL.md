---
name: update-docs
description: Skill for analyzing existing docs/ and AGENTS.md, then updating, reflecting, and fixing them to match the current codebase. Works via interactive dialogue (ask what changed) or auto-scan mode (detect drift between code and docs automatically). Covers all 7 docs/ files, AGENTS.md, and README.md. [Triggers: /update-docs, update docs, sync docs, fix docs, docs out of date, AGENTS.md outdated, reflect changes in docs, docs drift, documentation inconsistency, update AGENTS.md]
disable-model-invocation: true
---

# /update-docs — Documentation Sync & Update Skill

Skill for keeping existing `docs/` and `AGENTS.md` accurate and up-to-date. Detects inconsistencies between the current codebase and documentation, then applies targeted fixes.

> For generating documentation from scratch, use `/make-docs` instead.

## Quick Reference

| Task | Guide |
| ---- | ----- |
| What each doc file should contain | Read [references/doc-fields.md](references/doc-fields.md) (→ templates: [make-docs/references/templates.md](../make-docs/references/templates.md)) |
| Detecting drift patterns | Read [references/drift-patterns.md](references/drift-patterns.md) |

---

## Workflow

```txt
Phase 1: Scope Assessment (Interactive or Auto-scan)
  ↓
Phase 2: Drift Detection (compare code ↔ docs)
  ↓
Phase 3: Plan Fixes (show diff summary, confirm with user)
  ↓
Phase 4: Apply Updates
  ↓
Phase 5: Consistency Check (cross-file)
```

### Phase 1: Scope Assessment

**Interactive Mode** — Ask what changed since docs were last updated:

1. What was added, removed, or changed? (features, APIs, infra, deps)
2. Are there specific files known to be outdated?
3. Any constraints on what should NOT be changed?

**Auto-scan Mode** — When triggered without context, scan:

- `AGENTS.md` — tech stack, env vars, commands, constraints
- `docs/tech.md` — versions, deps, build tools
- `docs/design.md` — architecture, routing, binding names
- `docs/directory.md` — file structure
- `docs/tasks.md` — task status
- `docs/problems.md` — known issues
- `README.md` — project overview, badges, quick-start
- Key config files: `package.json`, `wrangler.toml`, `wrangler.jsonc`, `Cargo.toml`, `go.mod`, `Makefile`, `.env.example`

### Phase 2: Drift Detection

For each doc file, compare its content against the current code. Look for:

- Version numbers that don't match `package.json` / lock files
- Env var names that don't exist in code or `.env.example`
- File paths in `directory.md` that no longer exist
- Commands in `AGENTS.md` that fail or are renamed
- Tasks in `tasks.md` marked pending that are already merged
- Architecture descriptions that conflict with current routing/binding code
- README sections (install steps, env vars) that contradict `AGENTS.md` or `docs/`

### Phase 3: Plan Fixes

Before writing, show the user a summary:

```
[update-docs] Drift detected:
  docs/tech.md      — Hono version: docs=4.2.0, package.json=4.6.3
  AGENTS.md         — env var DB_NAME not in wrangler.jsonc
  docs/directory.md — src/routes/old-auth.ts listed but deleted
  docs/tasks.md     — "Add D1 migration" marked TODO, already merged in #42
  README.md         — install command uses old script name
Proceed with updates? (y/n)
```

### Phase 4: Apply Updates

- Edit only the affected sections, not entire files.
- Preserve existing formatting style and heading structure.
- When updating `docs/tech.md` versions, pull from `package.json` / lock file as the source of truth.
- When updating `AGENTS.md`, keep the same section structure.
- When updating `README.md`, keep the same tone and length; only fix factual errors.

### Phase 5: Consistency Check

After applying, verify cross-file consistency:

- Tech stack in `AGENTS.md` matches `docs/tech.md`
- Directory tree in `docs/directory.md` matches `docs/design.md` descriptions
- Environment variables consistent across `AGENTS.md`, `docs/design.md`, `docs/tech.md`
- README quick-start commands match `AGENTS.md` Key Commands
- No duplicate information pointing to conflicting values

---

## Agent Guidelines

- **Minimal Changes**: Only fix what is detectably wrong. Do not rewrite sections that appear correct.
- **Source of Truth Priority**: `package.json` > `wrangler.toml` > `docs/tech.md` > `AGENTS.md` for version/config facts.
- **Confirm Before Writing**: Always show the drift summary in Phase 3 before making edits, unless the user explicitly said to apply without confirmation.
- **One File at a Time**: Apply and verify one doc file before moving to the next.
- **Preserve Intent**: If a doc section seems intentionally simplified (e.g., design rationale), don't overwrite it with raw config values.
