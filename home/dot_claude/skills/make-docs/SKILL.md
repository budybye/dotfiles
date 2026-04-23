---
name: make-docs
description: "Skill for generating and maintaining a complete project documentation set - 7 files under /docs (requirements, design, tech, test, tasks, directory, problems) plus AGENTS.md and README.md. Works via interactive dialogue or auto-scan of the project directory. Includes a filled Hono + Cloudflare Workers example for reference. [Triggers: /make-docs, create docs, setup README, generate AGENTS.md, document project, design specs, requirements definition, write documentation, init docs]"
disable-model-invocation: true
---

# /make-docs — Project Documentation Generation Skill

Generate a complete documentation set for a project — 7 files under `docs/`, plus `AGENTS.md` and `README.md` at the root — by either interviewing the user or scanning an existing repository. Intended for greenfield documentation, not for keeping existing docs in sync.

> If `docs/` or `AGENTS.md` already exists, **stop and switch to `/update-docs`**. This skill assumes a blank slate and will overwrite conflicting content.

Decision tree for mode selection and the full definition-of-done checklist: [references/decision-guide.md](references/decision-guide.md).

## Critical Success Factors

To successfully use this skill, you must:
1. Clearly determine whether to use Interactive Mode or Auto-scan Mode BEFORE beginning Phase 1
2. Complete each phase fully before moving to the next
3. Verify consistency across all generated files before declaring completion
4. Never dump all files at once—follow the incremental delivery principle

## Quick Reference

| Task                                            | Guide                                                           |
| ----------------------------------------------- | --------------------------------------------------------------- |
| Mode selection (interactive vs auto-scan), Done criteria | Read [references/decision-guide.md](references/decision-guide.md) |
| Template for the 7 files under `/docs`          | Read [references/templates.md](references/templates.md)         |
| How to write `AGENTS.md` & `README.md`          | Read [references/root-docs.md](references/root-docs.md)         |
| Filled example (Hono + Cloudflare Workers)      | Read [references/examples.md](references/examples.md)           |

> 🚨 **Important**: Always read ALL reference files before beginning execution. Do not assume you know the content—the templates and examples contain critical details.

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

**Mode Selection Process** — Before doing anything else, explicitly determine which mode to use by following this decision process:

1. Is a working directory/repository provided?
   - No → Use Interactive Mode
   - Yes → Continue to step 2
2. Do `docs/` or `AGENTS.md` already exist in that directory?
   - Yes → STOP IMMEDIATELY and suggest `/update-docs`
   - No → Use Auto-scan Mode

**Interactive Mode** (When context is insufficient) — Ask 2–3 questions at a time:

1. Project purpose and goals.
2. Technical stack (Languages, frameworks, infrastructure).
3. Project stage (Early Dev / Production, etc.).
4. Target audience and key features.

For each question, wait for a response before asking the next. Do not ask all questions at once.

**Auto-scan Mode** (When a directory is provided) — Follow these steps in order:

1. Check if `docs/` or `AGENTS.md` already exists. If they do, stop and suggest `/update-docs` instead.
2. Scan structure and config files (e.g., `package.json`, `wrangler.toml`) using the commands in [references/templates.md](references/templates.md)
3. Identify gaps in information that require user input
4. Fill those gaps via a targeted dialogue (maximum 3 questions)

### Phases 2–4: Documentation Generation

Follow this strict sequence—do not skip or reorder phases:

- **Phase 2**: Generate the 7 files under `/docs` according to `references/templates.md`.
  - Generate one file at a time
  - Show each file to the user before proceeding to the next
  - Wait for user confirmation or feedback

- **Phase 3**: Generate `AGENTS.md` according to `references/root-docs.md`.
  - Cross-reference with information from Phase 2
  - Ensure consistency with technical details

- **Phase 4**: Generate `README.md` according to `references/root-docs.md`.
  - Link to the files created in Phase 2
  - Ensure all commands are copy-paste ready

## Agent Guidelines

- **Standard-first**: Prefer Web Standard APIs (`fetch`, Web Crypto, Web Streams) in `tech.md` and `design.md`. Note non-standard choices as ADR entries with rationale.
- **Single source of truth**: If the same fact would appear in multiple files, keep it in `/docs` and have the root files (`AGENTS.md`, `README.md`) link to it — never duplicate values.
- **Consistency gates**: Tech stack, env-var names, and commands must agree across every generated file before the skill is done.
- **Incremental delivery**: Do not dump all 9 files at once. Finish Phase 1 and surface a plan for user confirmation before writing Phases 2–4.
- **No placeholders at handoff**: Every `[Version]`, `[Feature Name]`, etc. must be replaced with a real value or explicitly marked "TBD — see `docs/tasks.md`".
- **Explicit verification**: After generating all files, explicitly verify consistency using the checklist in [references/decision-guide.md](references/decision-guide.md)
- **Clear handoff**: When complete, provide a summary that includes what was generated, what was inferred, and what needs manual verification

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
