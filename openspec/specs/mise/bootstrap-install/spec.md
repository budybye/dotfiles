# bootstrap-install Specification

## Purpose

Declarative installation of OS packages and bootstrap installer scripts through Mise, replacing duplicated Chezmoi lifecycle install scripts while preserving cross-platform coverage.

## Requirements

### Requirement: Single source of truth for OS packages

The system SHALL declare OS package installation intent exclusively in `home/private_dot_config/mise.toml` under `[bootstrap.packages]` for managers supported by Mise bootstrap (brew, brew-cask, mas, apt, and future supported managers).

#### Scenario: macOS package install via mise bootstrap

- **WHEN** `mise bootstrap packages apply` runs on macOS with brew packages declared in `mise.toml`
- **THEN** declared formulae and casks are installed or verified without executing Chezmoi `run_onchange_after_bootstrap.sh.tmpl`

#### Scenario: Linux package install via mise bootstrap

- **WHEN** `mise bootstrap packages apply` runs on Linux with apt packages declared in `mise.toml`
- **THEN** declared apt packages are installed or verified without executing Chezmoi `run_onchange_after_cli.sh.tmpl` or `run_onchange_after_gui.sh.tmpl`

### Requirement: Package list parity before script retirement

The system SHALL maintain parity between `packages.yaml` package lists and `mise.toml` `[bootstrap.packages]` entries before any overlapping Chezmoi install script is removed or disabled.

#### Scenario: Inventory reconciliation

- **WHEN** a migration task compares `packages.yaml` and `mise.toml` for a given platform and manager
- **THEN** every package still required by the repository is present in exactly one authoritative location (Mise) with no silent omissions

### Requirement: Installer scripts migrate to Mise tasks or bootstrap hooks

One-shot installer flows currently in `packages.yaml` `curl:` entries or Chezmoi bootstrap scripts (e.g. mise self-install, cursor install, coderabbit install) SHALL be expressed as Mise `[tasks]` or documented bootstrap hook steps, not as Chezmoi `run_onchange` shell loops.

#### Scenario: Curl installer replaced by mise task

- **WHEN** a tool previously installed via `packages.yaml` `curl:` entry is migrated
- **THEN** the equivalent install is invokable via `mise run <task>` or `mise bootstrap` without editing Chezmoi templates

#### Scenario: Idempotent re-run

- **WHEN** the migrated installer task or bootstrap step runs on a host where the tool is already installed
- **THEN** the step completes without error and does not corrupt existing installation state

### Requirement: Unsupported managers remain explicitly documented

Package managers not supported by Mise bootstrap (e.g. snap on Linux, Windows-specific installers) SHALL remain in Chezmoi scripts until a supported Mise path exists, and SHALL be listed in migration documentation as deferred.

#### Scenario: Snap packages deferred

- **WHEN** `packages.yaml` contains snap packages and Mise has no snap manager
- **THEN** `run_onchange_after_snap.sh.tmpl` continues to run and the deferral is recorded in `design.md` and `tasks.md`
