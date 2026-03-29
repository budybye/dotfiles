---
name: jj-vcs
description: Guide for Jujutsu (jj) VCS — Git-to-jj command mapping, colocated mode workflows, and output templates for commit messages, bookmark names, and PR descriptions. Always prefer jj commands over git when a .jj directory exists. [Triggers: /jj, jujutsu, jj st, jj log, jj new, jj commit, jj describe, jj squash, jj rebase, bookmark, colocated, push in jj, version control]
---

# Jujutsu (jj) VCS Best Practices

## Quick Reference

| Task                               | Guide                                                 |
| ---------------------------------- | ----------------------------------------------------- |
| Git to jj Detailed Command Mapping | Read [references/commands.md](references/commands.md) |
| Commit messages, bookmarks, PR body templates | Read [references/templates.md](references/templates.md) |

---

## Agent Guidelines

- **Always** prioritize `jj` commands over `git` if a `.jj` directory exists or the project is in colocated mode.
- **Never** perform a `git push` without verifying that the relevant bookmarks are set to the intended revisions.
- **Always** use the `--colocate` flag when initializing jj in an existing Git repository to maintain compatibility.
- **Prefer** `jj undo` for immediate operation reversal instead of manual reflog manipulation.

---

## Core Principles

- **Prioritize jj**: Use `jj` commands instead of `git` commands whenever possible.
- **Colocated Mode**: Coexist `.jj` and `.git` to maintain compatibility with existing Git tools and workflows.
- **Bookmarks**: The concept equivalent to Git branches is called a "bookmark" in jj.

## Core Concepts of jj

### Fundamental Differences from Git

| Concept            | Git                        | jj                                        |
| ------------------ | -------------------------- | ----------------------------------------- |
| Working Copy       | Manual `add` / `commit`    | Automatically committed                   |
| Staging            | Add to index via `git add` | None (does not exist)                     |
| Branches/Bookmarks | `branch` follows HEAD      | `bookmark` is moved manually              |
| Conflicts          | Blocks operations          | Committable; resolved later               |
| Descendants        | Manual rebase              | Automatic rebase                          |
| Stash              | `git stash`                | `jj new @-` (remains as a sibling commit) |
| Undo               | Manual restore from reflog | `jj undo` / `jj op revert`                |

### Automatic Working Copy Commits

In jj, any changes in your working directory are automatically recorded in a "working copy commit" (`@`).
`git add` is not required. New files and deletions are tracked automatically.

```bash
# Simply editing a file records the change
echo "hello" > file.txt
jj st           # Shows the changes
jj diff         # Shows the diff
```

### Basic Workflow

```bash
# 1. Start a new change from main
jj new main

# 2. Edit files (automatically tracked)
# 3. Add a message and start the next change
jj commit -m "feat: add new feature"

# 4. Create a bookmark and push
jj bookmark create my-feature -r @-
jj git push
```

## GitHub/GitLab Workflow

### Pushing for PR (Automatic Bookmark Name)

```bash
jj new main
# Do some work...
jj commit -m "feat: new feature"
# Push with an auto-generated bookmark name (@- = parent commit)
jj git push --change @-
```

### Pushing for PR (Named Bookmark)

```bash
jj new main
# Do some work...
jj commit -m "feat: new feature"
jj bookmark create my-feature -r @-
jj git push
```

### Addressing Review Comments (Append Commit Method)

```bash
jj new my-feature
# Fix things...
jj commit -m "address pr comments"
jj bookmark move my-feature --to @-
jj git push
```

### Addressing Review Comments (Rewrite/Squash Method)

```bash
jj new my-feature-    # The trailing - denotes the parent
# Fix things...
jj squash             # Merge into the parent commit
jj git push --bookmark my-feature
```

## Colocated Repositories

### Initialization

```bash
# Add jj to an existing Git repository (recommended)
jj git init --colocate

# Create a new repository
jj git init
```

In colocated mode, `.jj` and `.git` coexist, and Git state is automatically synchronized when running `jj` commands.

### GitHub CLI (gh) Integration

The `gh` command works out of the box in colocated repositories.
For non-colocated repos, set the following environment variable:

```bash
export GIT_DIR=$PWD/.jj/repo/store/git
```

## Common Patterns

### Stacking Multiple Changes

```bash
jj new main
# Change 1
jj commit -m "refactor: preparation"
# Change 2
jj commit -m "feat: core logic"
# Change 3 (in progress)
jj describe -m "test: add tests"
```

### Editing a Past Commit

```bash
# Directly edit a specific commit
jj edit <revision>
# After editing, return to a new working copy
jj new
```

### Resolving Conflicts

```bash
# You can commit even if there are conflicts
jj rebase -d main    # Won't block even if conflicts occur
jj st                # Check for conflicted files
# Edit files to resolve
jj st                # Confirm resolution
```

### Useful Revsets

```bash
# Local-only bookmarks
jj log -r 'bookmarks() && ~remote_bookmarks()'
# Diff from main
jj log -r 'remote_bookmarks()..@'
# My own changes
jj log -r 'mine()'
```

## Workflow Integration

### Shell Function Example (User's Existing Pattern)

The user utilizes a `jjj` function like this:

```bash
# jjj "message" "bookmark_name" "remote_name"
# - Defaults to an emoji if message is omitted
# - Auto-detects bookmark name (jj -> git -> main) if omitted
# - Defaults to "origin" for remote
```

This function bundles `jj describe` + `jj bookmark set` + `jj git push`.
Follow this pattern when suggesting new aliases or functions.

### Commit Messages

In jj, use `jj describe` to set a message.
Note that `jj commit -m "msg"` is a shortcut for `jj describe` + `jj new`.
