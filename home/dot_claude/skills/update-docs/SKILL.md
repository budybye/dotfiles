---
name: update-docs
description: "Skill for analyzing existing docs/ and AGENTS.md, then updating, reflecting, and fixing them to match the current codebase. Works via interactive dialogue (ask what changed) or auto-scan mode (detect drift between code and docs automatically). Covers all 7 docs/ files, AGENTS.md, and README.md. [Triggers: /update-docs, update docs, sync docs, fix docs, docs out of date, AGENTS.md outdated, reflect changes in docs, docs drift, documentation inconsistency, update AGENTS.md]"
disable-model-invocation: true
---

# /update-docs - Documentation Sync & Update Skill

Skill for keeping existing `docs/` and `AGENTS.md` accurate and up-to-date. Detects inconsistencies between the current codebase and documentation, then applies targeted fixes.

> For generating documentation from scratch, use `/make-docs` instead.

## Documentation Files Overview

The skill works with these 7 documentation files in the `docs/` directory, plus `AGENTS.md` and `README.md`:

1. `docs/requirements.md` - functional & non-functional requirements
2. `docs/design.md` - architecture, routing, binding names
3. `docs/tech.md` - versions, deps, build tools
4. `docs/test.md` - testing strategy, coverage targets, test commands
5. `docs/tasks.md` - task status
6. `docs/directory.md` - file structure
7. `docs/problems.md` - known issues

## Quick Reference

| Task                                    | Guide                                                                                                                                              |
| --------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| What each doc file should contain       | Read [references/doc-fields.md](references/doc-fields.md) (→ templates: [make-docs/references/templates.md](../make-docs/references/templates.md)) |
| Common drift patterns + how to detect   | Read [references/drift-patterns.md](references/drift-patterns.md)                                                                                  |
| Which file wins when two disagree       | Read [references/consistency-matrix.md](references/consistency-matrix.md)                                                                          |

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

**Interactive Mode** - Ask what changed since docs were last updated:

1. What was added, removed, or changed? (features, APIs, infra, deps)
2. Are there specific files known to be outdated?
3. Any constraints on what should NOT be changed?

**Auto-scan Mode** - When triggered without context, scan all 7 docs plus README and AGENTS, then the authoritative config files:

- `AGENTS.md` - tech stack, env vars, commands, constraints
- `docs/requirements.md` - functional & non-functional requirements
- `docs/design.md` - architecture, routing, binding names
- `docs/tech.md` - versions, deps, build tools
- `docs/test.md` - testing strategy, coverage targets, test commands
- `docs/tasks.md` - task status
- `docs/directory.md` - file structure
- `docs/problems.md` - known issues
- `README.md` - project overview, badges, quick-start
- Key config files: `package.json` (+ lock file), `wrangler.toml`, `wrangler.jsonc`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `Makefile`, `.env.example`, `.dev.vars.example`, `.tool-versions`, `mise.toml`

**Tools to use for scanning:**
- Use `bash` tool to run commands like `ls`, `find`, `grep` to check file existence and content
- Use `read` tool to examine file contents
- Use `git` commands via `bash` to check commit history for task status

### Phase 2: Drift Detection

For each doc file, compare its content against the current code using the `read` and `bash` tools. Look for:

- Version numbers that don't match `package.json` / lock files (use `read` to examine these files)
- Env var names that don't exist in code or `.env.example` (use `read` to examine these files)
- File paths in `directory.md` that no longer exist (use `bash` with `ls` or `find` to verify)
- Commands in `AGENTS.md` that fail or are renamed (use `read` to check `package.json` scripts)
- Tasks in `tasks.md` marked pending that are already merged (use `bash` with `git log` to check)
- Architecture descriptions that conflict with current routing/binding code (use `read` to examine source files)
- README sections (install steps, env vars) that contradict `AGENTS.md` or `docs/` (use `read` to compare)

### Phase 3: Plan Fixes

Before writing, show the user a summary:

```
[update-docs] Drift detected:
  docs/tech.md      - Hono version: docs=4.2.0, package.json=4.6.3
  AGENTS.md         - env var DB_NAME not in wrangler.jsonc
  docs/directory.md - src/routes/old-auth.ts listed but deleted
  docs/tasks.md     - "Add D1 migration" marked TODO, already merged in #42
  README.md         - install command uses old script name
Proceed with updates? (y/n)
```

### Phase 4: Apply Updates

- Edit only the affected sections, not entire files.
- Preserve existing formatting style and heading structure.
- When updating `docs/tech.md` versions, pull from `package.json` / lock file as the source of truth.
- When updating `AGENTS.md`, keep the same section structure.
- When updating `README.md`, keep the same tone and length; only fix factual errors.
- Use the `edit` tool to make precise changes to files, ensuring you only modify what needs to be changed.

### Phase 5: Consistency Check

After applying, verify cross-file consistency:

- Tech stack in `AGENTS.md` matches `docs/tech.md`
- Directory tree in `docs/directory.md` matches `docs/design.md` descriptions
- Environment variables consistent across `AGENTS.md`, `docs/design.md`, `docs/tech.md`
- README quick-start commands match `AGENTS.md` Key Commands
- No duplicate information pointing to conflicting values

---

## Agent Guidelines

- **Minimal changes**: Only fix what is detectably wrong. Do not rewrite sections that look correct - even if you could phrase them better.
- **Source-of-truth priority**: Lock file > `package.json` > `wrangler.{toml,jsonc}` > `docs/tech.md` > `AGENTS.md` for version and config facts. Full matrix in [references/consistency-matrix.md](references/consistency-matrix.md).
- **Confirm before writing**: Always present the Phase 3 drift summary before editing, unless the user explicitly waived confirmation.
- **One file at a time**: Apply and verify a single doc file before moving on. Batched writes make attribution impossible when a later edit is wrong.
- **Preserve intent**: If a section reads as deliberately simplified (e.g., ADR rationale, onboarding-oriented prose), do not overwrite it with raw config dumps.
- **Surface, don't silence**: When the upstream source itself looks wrong, stop and ask - do not align docs to a broken source and call it done.
- **Use appropriate tools**: Use `read` for examining file contents, `bash` for running commands, and `edit` for making changes.

## Examples

**Example 1: Version Drift Detection**
```
# Check package.json version
read: package.json
# Check docs/tech.md version
read: docs/tech.md
# If they differ, update docs/tech.md with the version from package.json
edit: docs/tech.md
```

**Example 2: Missing File Path**
```
# Check if a file mentioned in directory.md actually exists
bash: ls -la src/some-directory/
# If the file doesn't exist, remove it from directory.md
edit: docs/directory.md
```

**Example 3: Command Rename**
```
# Check package.json scripts
read: package.json
# Check AGENTS.md commands
read: AGENTS.md
# If they differ, update AGENTS.md to match package.json
edit: AGENTS.md
```
