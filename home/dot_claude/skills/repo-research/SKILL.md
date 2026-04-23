---
name: repo-research
description: "A skill for efficiently researching external libraries and repositories. Prefers Context7 MCP for documentation and ghq for local source exploration, with graceful fallback to WebSearch + direct git clone when those tools are unavailable. Guides the choice between \"read docs\" and \"read source\", and provides templates for recording findings. [Triggers: /repo-research, ghq, clone, context7, query-docs, resolve-library-id, research repo, investigate source, library docs, OSS review, how does X work internally]"
allowed-tools: Read, Grep, Glob, Bash
---

# /repo-research — Repository Research & Efficiency Skill

Two ways to learn an external library: **read its docs** (fast, shallow) or **read its source** (slow, deep). This skill picks the right one, runs it efficiently, and records the result.

## Quick Reference

| Task                                         | Guide                                                           |
| -------------------------------------------- | --------------------------------------------------------------- |
| Tool specs, commands, troubleshooting        | Read [references/tools.md](references/tools.md)                 |
| Research memo & session log templates        | Read [references/memo-template.md](references/memo-template.md) |
| Decision flow (docs vs source)               | See "Decision Criteria" below                                   |
| Context window management                    | See "Context Window Management" below                           |

---

## Agent Guidelines

- **Context optimization**: try Context7 (docs) before cloning any large repo.
- **Minimal reading**: inside a cloned repo, use `Grep` / `Glob` to localize files before `Read`. Never read the entire repo.
- **Path safety**: build absolute paths with `$(ghq root)` (or the fallback clone target). Relative paths break across environments.
- **Specific topics**: query Context7 with focused phrases ("middleware authentication redirect"), not vague ones ("how to use").
- **Record decisions**: even for one-off lookups, note the source and the conclusion. Next session's you will thank current you.
- **Always record findings**: Use the Research Memo Template to capture significant findings. This preserves context for future work and helps team members benefit from your research.

---

## Workflow

```txt
Phase 1: Need Assessment — "usage" vs "internals" vs "both"
  ↓
Phase 2: Documentation Research (Context7; fallback: WebSearch)
  ↓
Phase 3: Source Research (ghq; fallback: git clone) — optional
  ↓
Phase 4: Synthesis & Implementation
  ↓
Phase 5: Record Findings (use Research Memo Template)
```

### Phase 1 — Need Assessment

- **Usage** (how to call the library) → docs are usually enough
- **Internals** (how it works inside) → source is needed
- **Both** → docs first to orient, then source to confirm

### Phase 2 — Documentation Research

**Primary path (Context7 MCP)**:
1. `resolve-library-id` to resolve the library name
2. `query-docs` with a focused topic (2000–3000 tokens recommended)

**Fallback (no Context7)**:
1. `WebSearch` for `<library> <topic> site:<official-domain>`
2. `WebFetch` the most relevant official doc page

### Phase 3 — Source Research (optional)

**Primary path (ghq)**:
1. `command -v ghq` — verify ghq is installed
2. `ghq get <repo-url>`
3. `REPO_PATH="$(ghq root)/<host>/<owner>/<repo>"`
4. `Grep` / `Glob` inside `$REPO_PATH`, then `Read` 2–5 key files

**Fallback (no ghq)**:
1. `git clone --depth 1 <repo-url> /tmp/<repo-name>`
2. Same `Grep` / `Read` pattern in `/tmp/<repo-name>`
3. Clean up after session: `rm -rf /tmp/<repo-name>`

### Phase 4 — Synthesis & Implementation

Apply findings to your task. This may involve:
- Writing code that uses the library
- Debugging based on internal behavior insights
- Making architectural decisions informed by research

### Phase 5 — Record Findings

Always record significant findings using the Research Memo Template:
- After completing research that took more than 15 minutes
- Before moving to implementation to preserve context
- When the findings may be useful to team members later
- When investigating libraries you might revisit in future

See [references/memo-template.md](references/memo-template.md) for detailed templates.

---

## Decision Criteria

```text
Target is…

├─ Library usage, API specs, config shape
│  → Context7 (or WebSearch fallback). Cheap and fast.
│
├─ Internal algorithm, data structures, undocumented behavior
│  → ghq clone (or git-clone fallback). Read Grep-localized files.
│
└─ Both (usage + internals)
   → Context7 first (orient), ghq second (confirm).
```

### When docs are "not enough" — move to source

- Behavior described in docs contradicts what the code does
- The library's public API hides branching that matters (e.g., cache eviction timing)
- You need to copy a pattern (structure, test style) that docs don't spell out
- A version-specific bug — docs are ahead of or behind your pinned version

### Decision Flow Questions

When deciding between docs and source, ask:

1. **Can I solve this with API usage alone?** If yes, use Context7.
2. **Do I need to understand implementation details?** If yes, use ghq.
3. **Am I debugging unexpected behavior?** Start with Context7, move to ghq if docs don't explain it.
4. **Do I need to copy implementation patterns?** Use ghq to read source directly.

---

## Minimal command example

```bash
# Context7 (MCP)
# → resolve-library-id(query="Hono")
# → query-docs(library_id="/honojs/hono", topic="bearerAuth middleware", tokens=2500)

# ghq source exploration
ghq get github.com/honojs/hono
REPO="$(ghq root)/github.com/honojs/hono"
# Grep pattern: "bearerAuth" path: "$REPO/src/middleware"
# Read: relevant 2–3 files only
```

Fallback when neither MCP nor ghq is available:

```bash
git clone --depth 1 https://github.com/honojs/hono /tmp/hono
# Grep / Read in /tmp/hono as above
rm -rf /tmp/hono  # after notes are captured
```

## Context Window Management

When working with large documentation sets or repositories:

1. **Start smaller**: Begin with 2000-3000 tokens for Context7 queries
2. **Iterate topics**: Break broad questions into focused subtopics
3. **Use grep first**: In repositories, always grep for keywords before reading files
4. **Summarize early**: Capture key findings in memos to free up context space
5. **Read in slices**: For very large files, use offset/limit to read portions

If you encounter "context window exceeded" errors:
- Reduce Context7 tokens by half
- Focus on one specific aspect rather than broad topics
- Create interim summaries to compress information
- Use the research memo template to offload information from working memory
