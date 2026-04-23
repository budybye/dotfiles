# Drift Patterns Reference

Common patterns of drift between code and documentation. Consult during Phase 2 (Drift Detection) to widen coverage beyond what you'd catch by eye.

Each entry lists: **symptom → detection → fix**.

---

## Version drift

- **Symptom**: Versions in `docs/tech.md` or `AGENTS.md` disagree with `package.json` / lock file
- **Detection**: Diff `dependencies` / `devDependencies` in `package.json` against the versions recorded in `docs/tech.md`
- **Fix**: Take `package.json` as authoritative and update `docs/tech.md`

```
# Example
docs/tech.md:  Hono: 4.2.0
package.json:  "hono": "^4.6.3"
→ update docs/tech.md to 4.6.3
```

---

## Env-var / binding name mismatch

- **Symptom**: An env var or binding named in `AGENTS.md` / `docs/design.md` does not exist in `wrangler.*` (or vice versa)
- **Detection**: Cross-check `wrangler.*`'s `[vars]`, `[d1_databases]`, `[kv_namespaces]`, `[r2_buckets]`, `[durable_objects]` against what the docs reference
- **Fix**: `wrangler.*` wins. Remove bindings that no longer exist from docs; add bindings that docs omit if they're in active use

---

## Vanished file paths

- **Symptom**: Files or directories listed in `docs/directory.md` no longer exist
- **Detection**: For each path in `docs/directory.md`, verify existence with Glob / Read
- **Fix**: Remove deleted paths from docs. If newly added paths are architecturally significant, add them

---

## Command rename

- **Symptom**: `dev` / `deploy` / `test` commands in `AGENTS.md` differ from `package.json` scripts
- **Detection**: Compare the `scripts` section of `package.json` against the Key Commands in `AGENTS.md`
- **Fix**: `package.json` wins; update `AGENTS.md`

---

## Task-status drift

- **Symptom**: Items in `docs/tasks.md` marked TODO / In Progress are already implemented
- **Detection**: Cross-reference recent commits and merged PRs against entries in `tasks.md`
- **Fix**: Move completed items to Done. Add newly-started work if missing

---

## Stale architecture description

- **Symptom**: Routing / middleware composition in `docs/design.md` no longer matches the code
- **Detection**: Compare `src/index.ts` (or equivalent entry point) against `docs/design.md`
- **Fix**: Rewrite `design.md` to match the current routing. Preserve any rationale text (ADR entries) even when facts change

---

## README drift

- **Symptom**: README's install steps, env-var list, or commands contradict `AGENTS.md` / `docs/`
- **Detection**: Check each README section against `AGENTS.md` Key Commands, `docs/tech.md`, and `.env.example`
- **Fix**: Correct factual errors only. Preserve the README's tone and length — do not expand it into a technical reference

---

## AGENTS.md missing constraints

- **Symptom**: Constraints recorded in `docs/problems.md` are not reflected in the `AGENTS.md` Constraints section
- **Detection**: For each entry in `docs/problems.md`, check whether `AGENTS.md` mentions it
- **Fix**: Add agent-facing constraints (things an automated agent must avoid) to `AGENTS.md`. Leave purely informational entries in `problems.md` alone

---

## Cross-file inconsistency

- **Symptom**: The same fact is stated with different values across multiple files

**Examples**:
- Node version in `AGENTS.md` ≠ Node version in `docs/tech.md`
- Binding names in `docs/design.md` ≠ env-var section of `AGENTS.md`
- README quick-start ≠ `AGENTS.md` Key Commands

**Fix strategy**: Consult the "Source of truth" column in [doc-fields.md](doc-fields.md) and align the downstream files to the upstream value.
