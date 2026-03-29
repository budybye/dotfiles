# jj-vcs Output Templates

Templates for the text artifacts produced when using jj: commit messages, bookmark names, and PR descriptions.

---

## Commit Messages (Conventional Commits)

### Format

```
<type>(<scope>): <short description>

[optional body — explain WHY, not WHAT]

[optional footer — breaking changes, issue refs]
```

### Types

| Type | When to use |
|---|---|
| `feat` | New feature or behavior |
| `fix` | Bug fix |
| `refactor` | Code restructure without behavior change |
| `docs` | Documentation only |
| `test` | Add or fix tests |
| `chore` | Build, tooling, dependency updates |
| `ci` | CI/CD configuration |
| `perf` | Performance improvement |

### Examples

```
feat(auth): add Bearer token validation middleware

fix(api): handle null result from D1 prepared statement

refactor(users): extract zod schema to shared schemas/user.ts

docs(readme): add quickstart instructions for Docker setup

chore(deps): bump hono from 4.5.0 to 4.6.0

ci: add WSL2 job to test.yaml

feat(kv): add session TTL support

BREAKING CHANGE: session store now requires KV binding named SESSION_KV
```

### Scope Conventions

- Use the **module or directory name** as scope: `auth`, `api`, `db`, `kv`, `routes`, `workers`
- Omit scope for changes that span multiple areas
- Keep the description under **72 characters total** (type + scope + description)

---

## Bookmark Naming Convention

```
<type>/<short-kebab-description>
```

### Examples

```
feat/add-auth-middleware
fix/null-d1-response
refactor/extract-user-schema
docs/update-readme
chore/bump-hono
ci/enable-wsl2-job
```

### Rules

- Mirror the commit type in the bookmark name
- Use **kebab-case**, no underscores
- Keep it short and scannable (3–5 words max)
- Match the convention in `jj git push --change @-` auto-generated names when possible

---

## PR Body Template

Use this as the body for `gh pr create --body "..."`.

```markdown
## Summary

- [What this PR does in 1–2 sentences]
- [The problem it solves or feature it adds]

## Changes

- [Specific file/module change 1]
- [Specific file/module change 2]
- [...]

## Testing

- [ ] `make check` passes
- [ ] Manual test: [brief description of what was tested]
- [ ] No regressions in existing CI jobs

## Notes

[Optional: caveats, follow-up tasks, or context for reviewers]
```

### Minimal PR Body (small fixes)

```markdown
[One sentence describing the change and why.]

Fixes: #[issue number] (if applicable)
```

---

## jj describe Message (in-progress work)

When describing a work-in-progress commit with `jj describe`:

```
wip: [brief description of current state]

TODO:
- [ ] [what remains]
- [ ] [what remains]
```

Example:

```
wip: add user creation endpoint

TODO:
- [ ] add input validation
- [ ] write tests
- [ ] handle duplicate email error
```
