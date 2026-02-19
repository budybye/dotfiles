# [Feature Name] Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach. For dotfiles: which config files, template logic, OS conditions.]

**Tech Stack:** Chezmoi, [OS-specific tools], [relevant tech from docs/tech.md]

**Reference:** [docs/requirements.md](requirements.md), [docs/design.md](design.md), [docs/directory.md](directory.md)

---

## Prerequisites

- [ ] Worktree created (`git worktree add ../dotfiles-<feature> <branch>`)
- [ ] `make check` passes on main branch
- [ ] Target OS available for verification (or GitHub Actions)

---

### Task 1: [First Component]

**Files:**

- Create: `home/private_dot_config/<path>/<file>.tmpl`
- Modify: `docs/requirements.md:XX-YY`
- Verify: `chezmoi diff` after apply

**Step 1: Document expected behavior**

Add to docs/requirements.md or create verification checklist:

```markdown
## [Feature] Verification

- [ ] Condition A is met
- [ ] File X exists at path Y
```

**Step 2: Run check to establish baseline**

Run: `make check`
Expected: No unexpected diffs (or document current state)

**Step 3: Create minimal implementation**

```yaml
# Example: home/private_dot_config/example/config.tmpl
{{ if eq .chezmoi.os "linux" }}
setting = "linux-value"
{{ end }}
```

**Step 4: Verify implementation**

Run: `chezmoi apply`
Run: `chezmoi diff`
Expected: No diff (clean state)

**Step 5: Commit**

```bash
git add home/private_dot_config/<path>/
git commit -m "feat(config): add <feature> for <os>"
```

---

### Task 2: [Second Component]

**Files:**

- Modify: `path/to/file:line-range`

[Repeat Task structure...]

---

### Task N: [Final Task - Documentation]

**Files:**

- Modify: `docs/requirements.md`
- Modify: `README.md`
- Modify: `docs/tasks.md`

**Step 1:** Update requirement status
**Step 2:** Update README if user-facing
**Step 3:** Mark task complete in docs/tasks.md
**Step 4:** Commit

```bash
git add docs/ README.md
git commit -m "docs: update for <feature>"
```

---

## Post-Implementation Checklist

- [ ] `make check` passes
- [ ] `make init` works on target OS (or CI passes)
- [ ] docs/plan.md updated if new plan added
- [ ] All commits follow conventional commits
