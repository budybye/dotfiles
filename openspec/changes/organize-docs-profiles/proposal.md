## Why

Repo docs live as a stale wiki in `docs/` (duplicate tool lists, dead paths, a leftover task process). OpenSpec is empty after init, so there is no requirement source of truth. At the same time the machine still treats GitHub as one identity and Ubuntu as one package profile, even though `budybye`/`boborder` and `linux.cli`/`linux.gui` already exist as facts.

## What Changes

- Move surviving, still-correct content from `docs/*.md` into OpenSpec capabilities. Keep original stems as capability names. Capability files use `spec.md`.
- Fold C4 diagrams into `architecture` (`c4-*.md` filenames kept). Do not leave `docs/architecture/` as a second home.
- **BREAKING** (docs layout): after migration, delete `docs/` including architecture. Point README / AGENTS at `openspec/`.
- Stop republishing tool catalogs in markdown. Tool how-to comes from picked skills; install truth stays in `packages.yaml`, mise, and aqua.
- Default GitHub identity is `budybye`. `boborder` is reachable with `gh auth switch`. `dayjobdoor` is unused and out of scope.
- Split Ubuntu into desktop vs minimal by `.chezmoi.hostname`. Hostname table is the switch. `linux.gui` applies only to desktop hostnames.
- Drop `docs/tasks.md` (OpenSpec change `tasks.md` replaces it). Drop or absorb `docs/references.md` into `tech` (not a spec).

## Capabilities

### New Capabilities

- `documentation`: where project docs live, what gets deleted after migration, and the skill-not-catalog rule
- `directory`: layout and chezmoi source rules taken from the still-correct parts of `directory.md`
- `tech`: stack source-of-truth rules (packages.yaml / mise / aqua), no duplicated tool lists
- `security`: age, Bitwarden, SSH, and gh credential storage
- `go-template`: chezmoi Go template trim/quote rules
- `architecture`: C4 required views and the moved `c4-*.md` diagrams
- `github-identity`: default `budybye`, switchable `boborder`, no `dayjobdoor`
- `machine-profile`: hostname → desktop | minimal Ubuntu (and current Mac `101`)

### Modified Capabilities

- None. `openspec/specs/` is empty. This change introduces main specs via deltas.

## Impact

- `docs/` removed after apply (including C4).
- README, AGENTS.md, and any `docs/` links (CI `paths-ignore`, C4 cross-links, `directory.md` dead paths) retarget `openspec/`.
- Chezmoi data gains a hostname → profile map. Linux GUI packages/scripts gated on desktop hostnames.
- Git / `gh` default user `budybye`. `hosts.yml` must not pin `boborder` as the default user. No `includeIf` in this change.
- Graphify index is stale and must be rebuilt after the move.
