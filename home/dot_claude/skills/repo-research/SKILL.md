---
name: repo-research
description: A skill for efficiently researching external libraries and repositories. Uses Context7 MCP for documentation lookups and ghq for local source code exploration. Guides the choice between reading docs vs. cloning source, and provides templates for recording findings as research memos and session logs. [Triggers: /repo-research, ghq, clone, context7, query-docs, resolve-library-id, research repo, investigate source, library docs, OSS review, how does X work internally]
---

# /repo-research — Repository Research & Efficiency Skill

## Quick Reference

| Task                                  | Guide                                           |
| ------------------------------------- | ----------------------------------------------- |
| Tool Specifications & Command Details | Read [references/tools.md](references/tools.md)             |
| Decision Flow (Docs vs. Source)       | See the Decision Criteria below                             |
| Research memo & session log templates | Read [references/memo-template.md](references/memo-template.md) |

---

## Agent Guidelines

- **Context Optimization**: Always check if `Context7` (documentation) is sufficient before cloning a massive repository with `ghq`.
- **Minimal Reading**: When using `ghq`, use `Grep` or `SemanticSearch` to narrow down files before using `Read`. Never read the entire repository.
- **Path Construction**: Always use `$(ghq root)` to build absolute paths for reliability across different environments.
- **Specific Topics**: When querying `Context7`, use highly specific topics (e.g., "middleware authentication") instead of generic ones (e.g., "how to use").

---

## Workflow

```txt
Phase 1: Need Assessment
  ↓
Phase 2: Documentation Research (Context7)
  ↓
Phase 3: Source Code Research (ghq - Optional)
  ↓
Phase 4: Synthesis & Implementation
```

### Phase 1: Need Assessment

Identify if the user needs to know **how to use** a library (Docs) or **how it works** internally (Source).

### Phase 2: Documentation Research (Context7)

1. Use `resolve-library-id` to find the correct library ID.
2. Use `query-docs` with a specific topic and a token limit (2000-3000 recommended).

### Phase 3: Source Code Research (ghq)

1. If docs are insufficient, run `ghq get <repo_url>`.
2. Locate relevant code using `Grep` or `SemanticSearch` within the path provided by `ghq root`.
3. Read 2-5 key files to understand the core logic.

---

## Decision Criteria

```text
If the target is...

├─ Library usage, API specifications
│  → Use Context7 (Latest documentation)
│
├─ Internal implementation, algorithms, code structure
│  → Use ghq to clone and read the source code
│
└─ Both (Understanding usage + implementation)
   → Combine ghq + Context7
```

## Example Commands

```bash
# Retrieve a repository
ghq get github.com/vercel/next.js

# Build target path
REPO_PATH="$(ghq root)/github.com/vercel/next.js"

# Search within the repo
# Grep pattern: "middleware" path: "$REPO_PATH"
```
