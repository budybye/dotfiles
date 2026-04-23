---
name: jj-vcs
description: "Guide for Jujutsu (jj) VCS - when to use jj over git, colocated-mode workflow, and conceptual differences (automatic working-copy commits, bookmarks-not-branches, no index, commit-able conflicts). Detailed command mapping and output templates in references. Prefer jj commands whenever a .jj directory exists. [Triggers: /jj, jujutsu, jj st, jj log, jj new, jj commit, jj describe, jj squash, jj rebase, bookmark, colocated, push in jj, version control]"
---

# Jujutsu (jj) VCS Best Practices

A concise orientation for working in `jj`-managed repositories (colocated or native). For the full Git↔jj command mapping and message templates, follow the references below.

## Quick Reference

| Task                                            | Guide                                                     |
| ----------------------------------------------- | --------------------------------------------------------- |
| Full Git → jj command mapping                   | Read [references/commands.md](references/commands.md)     |
| Commit messages, bookmark names, PR body        | Read [references/templates.md](references/templates.md)   |

---

## Agent Guidelines

- **Prefer jj over git** whenever `.jj/` exists or the repo is in colocated mode. `git` commands still work but bypass jj's operation log and undo capability.
- **Never** run `git push` directly from a jj colocated repo without first confirming the relevant bookmarks point at the intended revisions (`jj bookmark list`).
- **Always** use `jj git init --colocate` when adding jj to an existing Git repo — preserves tooling compatibility.
- **Prefer `jj undo`** for reverting an operation over manually unwinding via reflog. It's atomic and cheap.
- **Move bookmarks explicitly** — unlike git branches they do not follow `HEAD`; forgetting to move them is the most common jj pitfall.

---

## Core Concepts

### Differences from Git

| Concept            | Git                        | jj                                        |
| ------------------ | -------------------------- | ----------------------------------------- |
| Working copy       | Manual `add` / `commit`    | Automatically recorded in `@`             |
| Staging area       | Index via `git add`        | None — does not exist                     |
| Branches           | `branch` follows `HEAD`    | `bookmark` moves explicitly               |
| Conflicts          | Block the operation        | Committable; resolved later               |
| Descendants        | Manual rebase              | Automatic rebase                          |
| Stash              | `git stash`                | `jj new @-` (parallel working copy)       |
| Undo               | Reflog + manual restore    | `jj undo` / `jj op revert`                |

### Automatic working-copy commits

Any edit in the working directory is recorded into the working-copy commit `@` automatically. No `git add` step.

```bash
echo "hello" > file.txt
jj st     # shows the change
jj diff   # shows the diff
```

### Bookmarks (≠ Git branches)

A bookmark is a **named pointer** to a revision. It does not auto-follow your current commit. You move it explicitly:

```bash
jj bookmark create my-feature -r @-
jj bookmark move my-feature --to @-
```

---

## Canonical Workflow

```bash
jj new main                  # start a new change from main
# ...edit files...
jj commit -m "feat: add X"   # describe + start next change
jj bookmark create my-feat -r @-
jj git push                  # push the bookmark
```

For further commands (describe, squash, rebase, resolve, etc.), see [references/commands.md](references/commands.md).

---

## Frequently Needed Patterns

### Push for PR

```bash
# With auto-generated bookmark name
jj git push --change @-

# With explicit bookmark
jj bookmark create my-feature -r @-
jj git push
```

### Address review comments

**Append a commit**:

```bash
jj new my-feature
# ...fix...
jj commit -m "address review"
jj bookmark move my-feature --to @-
jj git push
```

**Squash into the reviewed commit**:

```bash
jj new my-feature-         # trailing - = parent
# ...fix...
jj squash                  # merge into parent
jj git push --bookmark my-feature
```

### Stacking changes

```bash
jj new main
jj commit -m "refactor: preparation"
jj commit -m "feat: core logic"
jj describe -m "test: add tests"
```

### Resolve conflicts

```bash
jj rebase -d main    # does not block on conflicts
jj st                # shows conflicted files
# ...edit to resolve...
jj st                # confirm clean
```

---

## Colocated Mode

Initialize jj in an existing Git repo:

```bash
jj git init --colocate
```

`.jj/` and `.git/` coexist; jj keeps Git state in sync automatically when you run jj commands. The `gh` CLI and other Git tooling work without changes.

For non-colocated repos, `gh` needs:

```bash
export GIT_DIR=$PWD/.jj/repo/store/git
```

---

## Useful Revsets

```bash
jj log -r 'bookmarks() && ~remote_bookmarks()'   # local-only bookmarks
jj log -r 'remote_bookmarks()..@'                # diff from upstream
jj log -r 'mine()'                               # my changes
```

More revsets in [references/commands.md](references/commands.md#useful-revset-expressions).

---

## Team Collaboration

When adopting jj in a team environment, consider these best practices:

### Working with Git Tooling

In colocated mode, most Git tools work seamlessly:

```bash
# GitHub CLI works normally
gh pr create --title "Feature" --body "Description"

# Other Git tools also work
git log --oneline  # shows the same history
```

For non-colocated repos, export `GIT_DIR` to enable Git tooling:

```bash
export GIT_DIR=$PWD/.jj/repo/store/git
```

### Feature Branch Workflows

Create feature branches as bookmarks and keep them updated:

```bash
jj new main                    # start feature from main
jj commit -m "feat: add X"     # commit changes
jj bookmark create feature-x   # create bookmark
jj bookmark move feature-x     # move bookmark to latest commit
```

### Code Review Process

Use `jj git push --change` for easy PR creation:

```bash
jj git push --change @-  # pushes current commit as a PR
```

For updating PRs after review:

```bash
jj new feature-x         # start new commit on feature
# ...address feedback...
jj squash                # combine with parent commit
jj bookmark move feature-x  # update bookmark
jj git push              # push updated bookmark
```

### Common Team Pitfalls

1. **Bookmark synchronization**: Always move bookmarks explicitly after commits
2. **Conflicting pushes**: Use `jj git fetch` before pushing to avoid conflicts
3. **Operation log sharing**: jj's operation log is local-only; coordinate via Git remotes

---

## Notes on Messages

- `jj commit -m "msg"` is shorthand for `jj describe -m "msg"` + `jj new`.
- Editing a past revision's description: `jj describe <rev>`.
- Conventional Commits format and PR body templates: [references/templates.md](references/templates.md).
