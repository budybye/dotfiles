## Why

This repository already uses Chezmoi for dotfile deployment and lifecycle scripts, while `home/private_dot_config/mise.toml` already declares a large `[bootstrap.packages]` surface and macOS defaults. Package installation logic is duplicated across `.chezmoidata/packages.yaml`, Chezmoi `run_onchange_*` scripts, and Mise bootstrap config. Gradually moving install/bootstrap responsibilities to Mise reduces duplication, aligns with Mise's declarative `mise bootstrap` workflow, and keeps Chezmoi focused on templated config files, secrets, and host-specific branching that Mise cannot replace yet.

## What Changes

- Define a phased migration boundary: what moves to Mise bootstrap now vs what remains in Chezmoi for the foreseeable future.
- Consolidate OS package installation (Homebrew, apt, mas, snap where supported) under `mise.toml` `[bootstrap.packages]` as the single source of truth, then retire overlapping Chezmoi install scripts.
- Install mise via `curl https://mise.run` in root `install.sh` (before `chezmoi init --apply`) as the single canonical bootstrap entry on macOS/Linux; remove duplicate mise install paths from Chezmoi scripts.
- Migrate remaining one-shot installer flows (`cursor`, `coderabbit`, `zed`, etc.) from `packages.yaml` `curl:` entries into Mise `[tasks]`.
- Deduplicate macOS defaults: prefer existing `[bootstrap.macos.*]` in `mise.toml` over `run_onchange_after_defaults.sh` where equivalent.
- Preserve cross-platform support (macOS, Linux, Windows) and multi-GitHub-account SSH host-alias behavior without regression.
- Slim `packages.yaml` to Chezmoi-owned data only: `extensions`, `agents.skills`, and optionally `snap` / `windows` (or split to separate data files).
- **Explicitly not in scope for phase 1**: replacing Chezmoi templating, **encrypted dotfile lifecycle** (`encrypted_*`, `before_age`), **Bitwarden unlock** (`before_bw`), VS Code extension management, external archives, or full `[dotfiles]` migration. Runtime env secrets via mise `mise set --age-encrypt` / `[bootstrap.secrets]` are phase 3+ only.
- Document a dual-run workflow (`chezmoi apply` + `mise bootstrap`) during transition with clear ordering and idempotency expectations.
- **Phase 4 (after install parity):** simplify cross-platform branching via centralized `features` / `profile` context (coordinate with `maximize-chezmoi-features`); expand `docs/` with bootstrap flow, platform matrix, git→jj (Jujutsu) migration guide, doc index, audit checklist, security guide, and config cross-references for the hybrid mise+chezmoi model.
- **Phase 5 (assurance gates):** dotfiles audit (inventory, duplication, idempotency) and security review (secrets, CI/container boundaries, supply chain) — **baseline before retiring chezmoi install scripts**; post-migration pass after phase 1.

## Capabilities

### New Capabilities

- `mise/bootstrap-install`: Declarative OS package and installer-script management via Mise bootstrap, replacing overlapping Chezmoi install scripts.
- `mise/bootstrap-macos`: macOS system preferences and bootstrap-only setup owned by Mise rather than Chezmoi shell scripts.
- `hybrid/coexistence`: Rules for running Chezmoi and Mise together during migration, including cross-platform matrix and multi-GitHub-account constraints.

### Modified Capabilities

<!-- No existing OpenSpec capabilities under openspec/specs/ yet. -->

## Impact

- `home/private_dot_config/mise.toml` — primary target for migrated bootstrap declarations
- `home/.chezmoidata/packages.yaml` — package lists to reconcile or slim down
- `home/.chezmoiscripts/darwin/run_onchange_after_bootstrap.sh.tmpl` — candidate for retirement after parity
- `home/.chezmoiscripts/darwin/run_onchange_after_defaults.sh` — candidate for retirement after parity with `[bootstrap.macos.*]`
- `home/.chezmoiscripts/linux/run_onchange_after_{cli,gui,snap}.sh.tmpl` — candidate for retirement after parity
- `home/.chezmoi.toml.tmpl` — unchanged in phase 1; remains authority for host/user branching and secrets flags
- `home/.chezmoiscripts/run_once_after_ssh.sh.tmpl` — remains in Chezmoi (multi-account SSH)
- `home/.chezmoiscripts/run_onchange_after_vscode.sh.tmpl` — remains in Chezmoi (per prior decision)
- `install.sh` — add curl mise install after chezmoi, before `chezmoi init --apply`
- Root `.mise.toml` — add `setup` / bootstrap / docker / vm tasks; keep `Makefile` as thin compatibility wrapper (`make init` → `mise run setup`)
- Split Linux **CLI-only** vs **GUI** bootstrap packages before retiring chezmoi gui script (CI/headless must not pull xfce/xrdp)
- `docs/audit-checklist.md`, `docs/security.md`, `docs/README.md` — audit and security documentation (phase 5)
- Coordinate audit inventory with `openspec/changes/maximize-chezmoi-features` task 1.1
- External references: [mise bootstrap](https://mise.jdx.dev/bootstrap.html), [mise dotfiles](https://mise.jdx.dev/dotfiles.html) (deferred to later phases)
