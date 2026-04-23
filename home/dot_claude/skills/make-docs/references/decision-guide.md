# Decision Guide — Mode Selection and Definition of Done

A short playbook for two decisions that otherwise stall the workflow: **which mode to run in** and **when the skill is finished**.

## Critical Reminder

Before doing ANYTHING else, you MUST determine which mode to use. Do not proceed with any work until this decision is made.

---

## Mode Selection

Decide at the start of Phase 1. Do not switch modes mid-run; finish the iteration and re-enter if the mode was wrong.

```
                    ┌─ Is a working directory / repo in scope?
                    │
              No ───┤───── Yes
               │    │
Interactive    │    └─► Does docs/ OR AGENTS.md already exist?
Mode           │              │
(ask user)     │        Yes ──┤── No
               │         │    │
               │         │    └─► Auto-scan Mode
               │         │         (this skill)
               │         │
               │         └─► STOP — suggest /update-docs instead
```

### Interactive mode — when to choose

Choose Interactive Mode when:
- No repository at hand (greenfield planning, spec-first work)
- User explicitly says "walk me through it" / "let's design this together"
- Auto-scan found a directory but config files are empty / placeholder

In Interactive Mode:
1. Ask exactly 2-3 questions at a time
2. Wait for responses before asking more
3. Build a mental model of the project before generating docs

### Auto-scan mode — when to choose

Choose Auto-scan Mode when:
- A populated repo is provided and `docs/` / `AGENTS.md` are absent
- User just said "document this project"
- CI or scripting context (no human to interrogate)

In Auto-scan Mode:
1. Run the commands in [references/templates.md](references/templates.md) to gather context
2. Identify gaps in the information gathered
3. Ask targeted questions to fill only those gaps

### Hybrid Approach

After Auto-scan finishes Phase 1, the scan will have gaps (business rationale, target users, deadlines). Fill those via a **short** interactive pass — 2–3 questions at a time, not a full interview.

Never mix Interactive and Auto-scan approaches within the same phase. Complete one approach fully before transitioning to the other.

---

## Definition of Done

The skill is complete when **all** of the following hold. This is the gate to return control to the user.

### Structural

- [ ] All 7 files exist under `docs/`: `requirements.md`, `design.md`, `tech.md`, `test.md`, `tasks.md`, `directory.md`, `problems.md`
- [ ] `AGENTS.md` exists at the project root
- [ ] `README.md` exists (or was intentionally skipped with user acknowledgement)

### Content minimums (per file)

| File | Minimum bar |
|---|---|
| `requirements.md` | Project overview + at least one functional and one non-functional requirement |
| `design.md` | At least one module described + one ADR (even if trivial) |
| `tech.md` | Tech stack table populated with real versions (no `[Version]` placeholders) |
| `test.md` | Test framework named; coverage target stated (even "none" is acceptable) |
| `tasks.md` | At least one milestone or current-focus entry |
| `directory.md` | Directory tree reflects the actual repo, not the template |
| `problems.md` | At least one entry, or an explicit "none known" note |
| `AGENTS.md` | Prohibitions section has content; Key Commands match `package.json` scripts |
| `README.md` | Install command copy-pastes without edits; env-var section links to `.env.example` |

### Consistency gates

- [ ] Tech stack in `AGENTS.md` matches `docs/tech.md`
- [ ] Env-var names consistent across `AGENTS.md`, `docs/tech.md`, `README.md`, and `.env.example`
- [ ] Directory tree in `docs/directory.md` matches reality (run `ls` / `find` to verify)
- [ ] No `[placeholder]` strings left in any generated file

### Red flags that block "done"

- Generated files contain lorem-ipsum style placeholder text
- Commands shown in `README.md` quick-start fail when executed
- The user asked for incremental generation and Phases 2–4 dumped everything at once
- Any file exceeds 500 lines — you are probably duplicating information that belongs elsewhere

If any red flag triggers, the skill is **not** done even if every checkbox above is green.

---

## Handoff message

When done, the final user-facing message should state:

1. What was generated (file list with line counts)
2. What was scanned vs. guessed (separate these clearly)
3. What the user should verify by hand (anything inferred without a source)
4. Suggested next step: `/update-docs` once code evolves
