---
name: tidy-files
description: Organize and manage files, directories, and codebases using systematic approaches. Use when cleaning up messy directories, organizing project structures, refactoring code files, or establishing consistent file management practices.
---

# Tidy Files - Systematic File Organization

This skill provides methodologies and tools for organizing files, directories, and codebases in a systematic and maintainable way. It covers file organization principles, directory structure best practices, code file management, and automation techniques.

## When to Use

- Cleaning up messy or disorganized directories
- Establishing consistent project structures
- Refactoring codebases for better organization
- Creating maintainable file hierarchies
- Implementing systematic file naming conventions
- Managing large collections of files

## Execution Protocol

Follow these steps in order. Each step produces an artifact; proceed only after completing the previous step.

### Step 1: Audit

Inventory what exists before changing anything.

1. List all files in the target directory (recursive or top-level as appropriate)
2. Classify each file into one of these categories:
   - **dotfiles**: hidden config files (`.bashrc`, `.gitconfig`, etc.)
   - **config**: application settings (`.json`, `.yaml`, `.toml`, `.conf`)
   - **source**: code files (`.ts`, `.py`, `.rs`, `.go`, etc.)
   - **test**: test files (`*.test.*`, `*.spec.*`, `*_test.*`)
   - **docs**: documentation (`*.md`, `*.rst`, `*.txt`, `README*`)
   - **assets**: images, fonts, media (`.png`, `.jpg`, `.svg`, `.ttf`, etc.)
   - **build-artifacts**: temp/build outputs (`.log`, `.tmp`, `.o`, `.pyc`, `.class`)
   - **data**: datasets, databases (`.csv`, `.sql`, `.db`, `.sqlite`)
   - **scripts**: automation files (`.sh`, `.bash`, `.zsh`, `Makefile`)
   - **archives**: compressed files (`.zip`, `.tar.gz`, `.7z`, `.rar`)
   - **unclassified**: anything not matching the above
3. Output: a classification table (file path → category)

### Step 2: Design Target Structure

Based on the audit, propose where each category should live.

**Classification priority** (apply in order, first match wins):
1. **Project rules**: user-defined filename patterns → project-specific dirs
2. **Type rules**: extension → type-based dir (see category list above)
3. **Date rules**: mtime → date subdirectory (default: `YYYY/MM`)

**Directory conventions** (use these unless the project already has different conventions):
- dotfiles → manage via chezmoi (or `$XDG_CONFIG_HOME/<app>/` if not managed)
- config → `$XDG_CONFIG_HOME/<app>/` or project `config/`
- source → project `src/` or feature-based `packages/<name>/src/`
- test → `tests/` (unit/integration/e2e) or co-located `*.test.*`
- docs → project `docs/`
- assets → `assets/` or `$XDG_PICTURES_DIR/` for personal files
- build-artifacts → delete (after confirmation) or `.gitignore`
- data → project `data/` or `db/`
- scripts → project `scripts/`
- archives → `archives/` or `$HOME/Downloads/` for personal files

**For codebase projects**, prefer feature-based grouping when the project has distinct modules:
```
src/
  auth/       # feature module
  user/       # feature module
  shared/     # shared utilities
```
Prefer layer-based grouping when the project is small or monolithic:
```
src/
  components/
  services/
  utils/
```

### Step 3: Plan Moves

Before executing, produce a move plan:

1. Create a table: `current path → target path` for every file to move
2. Identify import/dependency impacts if moving source files (update paths, aliases, CI configs)
3. Order moves: dotfiles first → config → source → everything else; deletions last
4. Include a **dry-run** mode that prints moves without executing
5. Include a **rollback** strategy: git branch + tag before any moves

### Step 4: Execute (with confirmation gates)

1. Create git branch and tag: `git checkout -b reorg/tidy && git tag pre-tidy`
2. For each batch in the move plan:
   a. Print what will be moved/deleted
   b. Ask for confirmation (or skip if `--yes` flag)
   c. Execute the moves
   d. Run verification (tests, build, lint) after each batch
   e. Commit: `git commit -m "reorg: batch N - description"`
3. After all batches, run full verification suite
4. Final commit and branch merge

### Step 5: Verify

1. Check no files were lost: compare file count before vs after
2. Verify imports/dependencies resolve: build + test pass
3. Confirm directory structure matches the design from Step 2
4. Clean up any empty directories left behind

## Classification Decision Rules

When a file matches multiple categories, resolve in this order:
1. **Explicit user instruction** → always wins
2. **Project rule** (filename pattern match) → next priority
3. **Test file** (even in source dir) → classify as test
4. **Extension-based type** → fallback

For ambiguous files (no extension, dual extension like `.tar.gz`):
- Dual extensions: use compound type (`tar.gz` → archives)
- No extension: check file content (`file` command) or classify as unclassified
- Symlinks: classify based on target; broken links → `broken-links/`
- Zero-byte files: → `empty-files/` (likely corrupt or in-progress)

## Quick Reference

| Task | Guide |
|------|-------|
| Basic file organization principles | Read [references/principles.md](references/principles.md) |
| Code file structuring techniques | Read [references/code-organization.md](references/code-organization.md) |
| Directory structure design | Read [references/directory-structure.md](references/directory-structure.md) |

> Only read reference files when you need deeper examples or pattern catalogs. The execution protocol above is self-contained for most tasks.

## Common Patterns

1. **Categorization First**: Group similar files before organizing (Step 1)
2. **Consistent Naming**: Apply uniform naming conventions (see principles reference)
3. **Hierarchical Structure**: Create logical directory hierarchies (see directory-structure reference)
4. **Automation Where Possible**: Use scripts with dry-run and confirmation gates (Step 3-4)
5. **Documentation**: Maintain organization documentation (README per directory)

## Red Flags to Watch For

| Issue | Solution |
|-------|----------|
| Inconsistent naming conventions | Establish and enforce standards (Step 2) |
| Deeply nested directories | Flatten structure where possible (max 4 levels) |
| Mixed file types in directories | Separate by function or type (Step 1 audit) |
| Poorly named files | Rename with descriptive names (Step 3) |
| Lack of documentation | Add README files and comments (Step 5) |
| No rollback plan | Always create git branch + tag before moves (Step 3) |

## Related Skills

- `xdg-base` - XDG Base Directory specification management
- `dotfiles-management` - Dotfiles organization and maintenance (via chezmoi)