## 0. Bootstrap entry: `install.sh` owns mise (do first)

- [ ] 0.1 Add idempotent mise install to `install.sh` after chezmoi and before `chezmoi init --apply`: `curl -fsSL https://mise.run | sh`, export `PATH="${HOME}/.local/bin:${PATH}"`, verify `mise --version` succeeds
- [ ] 0.2 Remove duplicate mise install logic from `run_once_before_bw.sh.tmpl` (`mise_install`), `linux/run_onchange_after_cli.sh.tmpl` (`install_mise`), and `darwin/run_onchange_after_bootstrap.sh.tmpl` (`brew install mise` / `install_mise`) — verify `make init` on a host without mise still gets mise before first `chezmoi apply`
- [ ] 0.3 Remove `curl -fsSL https://mise.run | sh` from `packages.yaml` `curl:` and `"brew:mise"` from `mise.toml` if declared — verify no remaining script installs mise except `install.sh` (optional fallback in `before_*` only)
- [ ] 0.4 Simplify `run_once_before_age.sh.tmpl` to prefer `mise use -g -y age` when mise is on PATH (installed by `install.sh`) — verify age decrypt path still works on fresh `make init`

## 1. Inventory and parity baseline

- [ ] 1.1 Generate a package parity table comparing `home/.chezmoidata/packages.yaml` (darwin formula/cask, linux cli/gui, mas) against `home/private_dot_config/mise.toml` `[bootstrap.packages]` and save it under `docs/` or as a comment block in the change — verify every required package appears in exactly one authoritative row
- [ ] 1.2 Run `mise bootstrap packages status` on macOS and capture output — verify no unexpected `missing` entries for brew/brew-cask/mas packages already declared in `mise.toml`
- [ ] 1.3 Run `mise bootstrap packages status` on Linux (VM or host) and capture output — verify apt-declared packages report expected state without invoking `run_onchange_after_cli.sh.tmpl`

## 2. Fill `mise.toml` package gaps

- [ ] 2.0 Split Linux bootstrap packages: move GUI-only apt entries (xfce4, xrdp, pipewire, plank, remmina, fcitx5-mozc, etc.) out of default `[bootstrap.packages]` into `[tasks.bootstrap-gui-packages]` or keep in chezmoi gui script until task exists — verify `mise bootstrap packages apply` on a headless Ubuntu (CI-like) does **not** install desktop stack
- [ ] 2.1 Add any **CLI** packages present only in `packages.yaml` `linux.cli` / `darwin` to `home/private_dot_config/mise.toml` under the correct manager prefix (`brew:`, `brew-cask:`, `mas:`, `apt:`) — verify `mise bootstrap packages status` shows zero unresolved gaps from the parity table
- [ ] 2.2 Confirm `mas:*` entries cover App Store apps currently installed via `run_onchange_after_bootstrap.sh.tmpl` mas loop — verify `mas list` or bootstrap status matches expected app IDs
- [ ] 2.3 Document snap packages as Chezmoi-retained in `design.md` deferral table if not already listed — verify `linux/run_onchange_after_snap.sh.tmpl` remains referenced and no snap entries were added to `mise.toml`

## 3. Migrate app curl installers to Mise tasks (mise itself stays in install.sh)

- [ ] 3.1 Add idempotent `[tasks.bootstrap-cursor]`, `[tasks.bootstrap-coderabbit]`, and `[tasks.bootstrap-zed]` to `home/private_dot_config/mise.toml` — verify each task exits 0 when the target binary already exists (do NOT add bootstrap-mise task; mise is installed by `install.sh`)
- [ ] 3.2 Add meta-task `[tasks.bootstrap-curl-installers]` running cursor/coderabbit/zed tasks — verify `mise run bootstrap-curl-installers` completes after `chezmoi apply` without Chezmoi curl loops
- [ ] 3.3 Remove migrated `curl:` entries from `packages.yaml` (cursor, coderabbit, zed; mise already removed in 0.3) — verify no Chezmoi script still references removed curl lines

## 4. macOS defaults deduplication (phase 2 within this change)

- [x] 4.1 Build a gap table from the legacy macOS defaults definitions in `design.md` § macOS defaults parity map — verified each call is mapped to Mise, an explicit task, deferred handling, or omission
- [x] 4.2 Port missing safe UI defaults into `home/private_dot_config/mise.toml` or `macos-defaults-extra` — verified with `mise bootstrap macos defaults status`
- [x] 4.3 Retire the old Chezmoi defaults hook after Mise became authoritative — verified no duplicate defaults hook remains

## 5. Retire overlapping Chezmoi install scripts

> **Gate:** Complete **§10 baseline audit** and **§11.1 security review (S1–S6)** before merging tasks 5.1–5.3.

- [ ] 5.1 Add early-exit guard at top of `home/.chezmoiscripts/darwin/run_onchange_after_bootstrap.sh.tmpl` delegating package installs to Mise — verify `chezmoi apply` logs skip message and `brew list` state still matches after `mise bootstrap packages apply`
- [ ] 5.2 Add early-exit guard to `home/.chezmoiscripts/linux/run_onchange_after_cli.sh.tmpl` and `run_onchange_after_gui.sh.tmpl` — verify Linux `chezmoi apply` skips apt loops when Mise bootstrap already converged packages
- [ ] 5.3 Slim `packages.yaml`: remove `darwin`/`linux`/`curl`/`python` and commented `# cargo`/`# npm`/`# go` blocks (already in `mise/config.toml`); retain `extensions`, `agents.skills`, and `snap` (and `windows` if not split) — verify Chezmoi templates still render without missing `.packages.*` keys

## 6. Hybrid workflow, Makefile compatibility, and documentation

- [x] 6.1 Document profile-specific setup: local `make init`; Mac CI `make init` then brew/brew-cask/mas/defaults/launchd workflow steps; Ubuntu CI `ci.toml`; Docker `docker.toml` — verified in `docs/bootstrap.md`
- [ ] 6.2 Confirm `ssh_setup` remains explicit and non-destructive while encrypted SSH files, `config.tmpl`, and `authorized_keys.tmpl` remain Chezmoi-managed; verify `chezmoi apply` does not generate or replace SSH keys, and `ssh_setup --generate` is required for new key creation
- [ ] 6.3 Add root `.mise.toml` tasks: `setup`, `install`, `apply`, `bootstrap:packages`, `bootstrap:macos`, `bootstrap:tools`, `post-apply` — verify `mise run setup` matches documented flow
- [ ] 6.4 Refactor `Makefile` to thin wrappers delegating to mise (`init` → `mise run setup`, `apply` → `mise run apply`, `test` → `mise run test`) — verify `.github/workflows/test.yaml` `make init` still passes on ubuntu-amd64
- [ ] 6.5 Migrate Makefile docker/vm targets to `.mise.toml` (`docker:build`, `docker:run`, `vm:create`, …) with Makefile aliases — verify `make docker-build` and `mise run docker:build` behave identically
- [ ] 6.6 Document zsh stack: ZDOTDIR (`dot_zshenv`) + chezmoi `~/.config/zsh/*` + sheldon (`plugins.toml`) + mise activate in `.zshrc` + platform-specific login shell handling — verify fresh Linux `make init` lands in zsh with sheldon and mise on PATH
- [x] 6.7 Document Linux profiles: CLI-only (CI/headless) vs GUI (Ubuntu VM xfce/xrdp + `run_once_after_setup.sh`) vs Docker (`DOCKER=true` guards) — verified in `docs/platform-matrix.md`
- [x] 6.8 Add `home/private_dot_config/mise/ci.toml` (macOS full / Linux CLI) and `docker.toml` (Linux CLI only); verify both parse independently
- [x] 6.9 Rename current image flavor `slim` to `full`, preserve separate `dev`, retain temporary `slim` full alias, and remove full/dev registry cache — verify workflow YAML parses

## 7. Docker simplification (phase 3 — optional within this change)

- [ ] 7.0 Add `[tasks.bootstrap-docker]` to `mise.toml` mirroring `run_once_after_docker.sh` Docker CE apt repo install (idempotent) — verify `mise run bootstrap-docker` on Ubuntu installs `docker` + compose plugin
- [ ] 7.1 Remove `install_act()` curl path from `run_once_after_docker.sh`; rely on `act` in `mise/config.toml` — verify `act --version` after `mise install`
- [ ] 7.2 Document devcontainer quirks: `DOCKER=true`, age/BW disabled, `dev` vs `ubuntu` user mismatch, `privileged` + xrdp ports — verify `design.md` Docker section matches `.devcontainer/*` and `Makefile` docker targets
- [ ] 7.3 (Optional) Add CLI-only `.devcontainer/Dockerfile.cli` without XFCE/xrdp for faster headless dev — verify image builds and `chezmoi apply` succeeds with template guards

## 8. Validation and rollback readiness

- [x] 8.1 Run `openspec validate chezmoi-to-mise-migration --strict` after implementation — verified validation passes
- [ ] 8.2 Run `chezmoi apply --dry-run` and `mise bootstrap packages status` on each supported OS in scope — verify no template errors and bootstrap status is clean
- [ ] 8.3 Document rollback steps (re-enable Chezmoi scripts, restore `packages.yaml` lists from git, restore Makefile if needed) in `design.md` Migration Plan section — verify rollback instructions reference specific files and guards added in tasks 5.x

## 9. Cross-platform simplification & documentation (phase 4 — after phase 1 parity)

Coordinate with `openspec/changes/maximize-chezmoi-features` tasks 1.2, 6.1, and 5.2.

- [ ] 9.1 Add `home/.chezmoidata/host_profiles.yaml` (or equivalent) and refactor `home/.chezmoi.toml.tmpl` to derive `env`, `profile`, `features`, and `identity` from env-overlays + host profile — verify `chezmoi data` on mac, linux personal, and `GITHUB_ACTIONS=true` matches expected booleans without username `if/else` chains for secrets
- [ ] 9.2 Simplify `home/.chezmoiignore` to use `features.*` gates instead of repeating `github`/`bitwarden`/`age`/`ssh` blocks — verify `chezmoi ignored` output is unchanged on representative hosts (diff before/after)
- [ ] 9.3 Add `docs/platform-matrix.md`: mac / linux-cli / linux-gui / windows / docker-ci ownership table (mise vs chezmoi per row) — verify every row links to a real config path
- [ ] 9.4 Add `docs/bootstrap.md`: `make init` → `mise run setup` flow, CLI vs GUI profile, when to run `chezmoi apply` twice — verify commands match implemented tasks from section 6
- [ ] 9.5 Add `docs/context.md`: document `chezmoi data` keys (`osid`, `env`, `profile`, `features`, `identity`) and `.chezmoiignore` rules — verify examples run with `chezmoi execute-template`
- [ ] 9.6 Update `docs/tech.md`, `docs/references.md`, `docs/problems.md`, and `AGENTS.md` for hybrid ownership (`mise.toml` OS packages, slim `packages.yaml`, bootstrap URLs) — verify no doc still lists `packages.yaml` darwin/linux as authoritative after phase 1 slimming
- [ ] 9.7 (Optional) Add CI-safe fixture checks: `chezmoi data` for labeled contexts under `docs/fixtures/` or workflow step — verify template render succeeds for darwin, linux-cli, windows, github-actions without host secrets
- [ ] 9.8 Add `docs/git-to-jj.md`: colocated migration, git↔jj command table, `jjj` usage, `_reserve/*` bookmarks, Makefile→mise `vcs:*` migration plan — verify doc links to `executable_jjj` and `claude/rules/git.md`; add `jj = "latest"` to `mise/config.toml` and `.mise.toml` tasks `vcs:status` / `vcs:push` (delegating to `jjj`) when implementing

## 10. Dotfiles audit (phase 5 — gate before §5 script retirement)

Coordinate with `maximize-chezmoi-features` task 1.1; reuse parity table from §1.1 where possible.

- [ ] 10.1 **Baseline audit (required before §5):** Run managed/unmanaged/ignored inventory (`chezmoi managed`, `chezmoi unmanaged`, `chezmoi ignored`); map each `.chezmoiscripts/**` script to mise vs chezmoi owner; list all `encrypted_*` paths — verify audit artifact committed as `docs/audit-report-YYYY-MM.md` (no secrets) or OpenSpec appendix
- [ ] 10.2 **Post-migration audit (after §5.3):** Re-run inventory; confirm zero duplicate package authority (YAML vs `mise.toml`); verify idempotent double-apply (`chezmoi apply` + `mise bootstrap packages apply` ×2) — verify parity table shows single owner per package row
- [ ] 10.3 **Post-context audit (after §9.1–9.2):** Diff `chezmoi ignored` and `chezmoi data` across darwin, linux-cli, github-actions, docker fixtures — verify CI profile never gains age/BW/ssh secrets
- [ ] 10.4 Add `docs/audit-checklist.md` with repeatable steps, cadence (baseline / post-migration / quarterly), and command reference — verify checklist covers mise hybrid scope (not chezmoi-only)
- [ ] 10.5 Add `docs/README.md` doc index: tier (entry / operations / reference / assurance), canonical path per topic, links to `bootstrap.md`, `platform-matrix.md`, `security.md` — verify no doc claims `packages.yaml` as OS package authority after phase 1

## 11. Security review (phase 5 — baseline + post-migration)

- [ ] 11.1 **Baseline review (required before §5):** Execute checks S1–S6 from `design.md` — (S1) secret scan recent `home/` history, (S2) dry-run without age key on CI profile, (S3) `chezmoi data` with `GITHUB_ACTIONS=true`, (S4) Dockerfile has no embedded secrets, (S5) inventory `curl | sh` usage, (S6) `chezmoi verify` on representative host — verify findings logged in `docs/security.md` § Open findings with severity
- [ ] 11.2 **Post phase 1 review:** Re-run S5 (mise `[tasks]` curl installers), S8 (tasks do not log secrets) — verify no new supply-chain URLs without documentation in `security.md`
- [ ] 11.3 **Post phase 4 review:** Re-run S3, S7, S10 after `features.*` refactor — verify fixture tests prove secrets cannot re-enable via host profile typo
- [ ] 11.4 Add `docs/security.md`: threat model table (age, BW, SSH, curl\|sh, mise vs chezmoi age keys, devcontainer), checklist S1–S10, secret boundary diagram, coordination with `maximize-chezmoi-features` §4 — verify doc links to `.chezmoi.toml.tmpl`, `before_age`, `before_bw`, encrypted SSH files, and `executable_ssh_setup`
- [ ] 11.5 (Optional) Add CI step: `chezmoi data` + template render for `GITHUB_ACTIONS=true` and `DOCKER=true` without host secrets — verify workflow fails if `age` or `bitwarden` true on CI profile
