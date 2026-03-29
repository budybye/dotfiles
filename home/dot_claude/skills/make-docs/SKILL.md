---
name: make-docs
description: Skill for generating and maintaining a complete project documentation set — 7 files under /docs (requirements, design, tech, test, tasks, directory, problems) plus AGENTS.md and README.md. Works via interactive dialogue or auto-scan of the project directory. Includes a filled Hono + Cloudflare Workers example for reference. [Triggers: /make-docs, create docs, setup README, generate AGENTS.md, document project, design specs, requirements definition, write documentation, init docs]
---

# /make-docs — Project Documentation Generation Skill

Skill for structuring project overviews by collecting information through interactive dialogue or scanning directory contents.

> If `docs/` or `AGENTS.md` already exists, use `/update-docs` to sync them instead.

## Quick Reference

| Task                                   | Guide                                                   |
| -------------------------------------- | ------------------------------------------------------- |
| Template for the 7 files under `/docs` | Read [references/templates.md](references/templates.md) |
| How to write `AGENTS.md` & `README.md` | Read [references/root-docs.md](references/root-docs.md) |
| Filled example (Hono + Cloudflare Workers) | Read [references/examples.md](references/examples.md) |

---

## Workflow

```txt
Phase 1: Information Gathering (Dialogue or Auto-scan)
  ↓
Phase 2: Generate Documentation under /docs (7 files)
  ↓
Phase 3: Generate AGENTS.md
  ↓
Phase 4: Maintain README.md
  ↓
Phase 5: Consistency Check & De-duplication
```

### Phase 1: Information Gathering

**Interactive Mode** (When context is insufficient) — Ask 2–3 questions at a time:

1. Project purpose and goals.
2. Technical stack (Languages, frameworks, infrastructure).
3. Project stage (Early Dev / Production, etc.).
4. Target audience and key features.

**Auto-scan Mode** (When a directory is provided) — First check if `docs/` or `AGENTS.md` already exists. If they do, stop and suggest `/update-docs` instead. Otherwise, scan structure and config files (e.g., `package.json`, `wrangler.toml`), then fill in the gaps via dialogue.

### Phases 2–4: Documentation Generation

- **Phase 2**: Generate the 7 files under `/docs` according to `references/templates.md`.
- **Phases 3 & 4**: Generate `AGENTS.md` and `README.md` according to `references/root-docs.md`.

## Agent Guidelines

- **Standard-First**: Always prioritize Web Standard APIs (fetch, Web Crypto) in `tech.md` and `design.md`.
- **Source of Truth**: If information is duplicated, designate one file (usually in `/docs`) as the source and link others to it.
- **Consistency**: Ensure tech stacks and environment variables match across all generated files.
- **Incremental**: Don't dump all files at once; confirm the direction with the user after Phase 1.

---

## Output File List

```txt
project-root/
├── README.md
├── AGENTS.md
└── docs/
    ├── requirements.md
    ├── design.md
    ├── tech.md
    ├── test.md
    ├── tasks.md
    ├── directory.md
    └── problems.md
```

---

## Related Skills

- **`/update-docs`** — Use this when docs already exist and need to be synced with the current codebase.
