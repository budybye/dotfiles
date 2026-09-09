## Context

See `proposal.md` for why. `openspec/specs/` is empty. Surviving truth is split across stale `docs/`, C4 under `docs/architecture/`, and live config (`packages.yaml`, mise, aqua, `.chezmoi.toml.tmpl`, `gh` hosts). Hostname `101` is this Mac; `589` is an existing special case. `gh` already has `budybye`, `boborder`, and unused `dayjobdoor` logins.

## Goals / Non-Goals

**Goals:**
- Land eight new main specs via this change's deltas
- Relocate C4 files into `openspec/specs/architecture/` keeping `c4-*.md` names
- Gate Linux GUI on hostname profile data
- Make `budybye` the configured default; keep `boborder` as a manual `gh auth switch`

**Non-Goals:**
- Path-based git `includeIf`
- Supporting or documenting `dayjobdoor`
- Inventing Ubuntu hostnames that are not supplied
- Rewriting C4 diagrams unless a link target breaks
- Implementing package installs in this planning change (apply phase)

## Decisions

### Capability = old stem, file = spec.md
Keeps the user's "filename stays" rule without breaking OpenSpec's `specs/<cap>/spec.md` layout.

Alternative considered: dump `docs/*.md` unchanged into `openspec/specs/`. Rejected — CLI and archive expect `spec.md`.

### C4 sits inside `architecture`, not a leftover `docs/` tree
`spec.md` is the contract. `c4-*.md` move as sibling files. After apply, delete `docs/` entirely.

Alternative considered: leave `docs/architecture/`. Rejected by the user.

### Hostname table in chezmoi data
A small map (hostname → `desktop` | `minimal` | `darwin`) in `.chezmoidata`. `101` → darwin/desktop. Ubuntu rows filled when known. Unknown host fails closed or uses a documented safe default (minimal on Linux).

Alternative considered: username or env var. Rejected — fleet already uses numeric hostnames.

### GitHub switch is CLI, not includeIf
Default identity and `gh` user = `budybye`. `boborder` via `gh auth switch`. Fix source `hosts.yml` so `user:` is not `boborder`. Do not mention `dayjobdoor` in specs or README.

Alternative considered: SSH host aliases (`github.com-boborder`). Deferred; switch is enough.

### Content filter
Copy only still-correct prose. Drop dead paths (`docs/plans/`, `docs/plan.md`, `docs/reference.md`). Drop `docs/tasks.md`. Fold `problems.md` scenarios into security / machine-profile. Do not copy tool lists from `requirements.md` / `tech.md`.

## Risks / Trade-offs

- [Unknown Ubuntu hostnames] → Spec allows adding rows later; apply MUST NOT assume desktop
- [Link rot after deleting `docs/`] → Grep and retarget README, AGENTS, CI `paths-ignore`, C4 cross-links
- [hosts.yml vs GITHUB_TOKEN] → Default user in source is `budybye`; token env may still override in CI
- [Stale graphify] → `graphify update .` after the move
- [Wide change] → One change now; split only if apply review is too large

## Migration Plan

1. Write / review this change's artifacts (this phase).
2. On apply: create `openspec/specs/<cap>/spec.md` from deltas, move C4 siblings, add hostname data, fix `gh` default user.
3. Retarget links. Delete `docs/`.
4. Rebuild graphify. `openspec archive` after verify.
5. Rollback: git revert the apply commit; `docs/` returns.

## Open Questions

- Exact Ubuntu hostname rows for desktop vs minimal (does not change specs; table is data).
