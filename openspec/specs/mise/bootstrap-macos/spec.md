# bootstrap-macos Specification

## Purpose

macOS workstation preferences and bootstrap-only system setup owned by Mise `[bootstrap.macos.*]` instead of imperative Chezmoi shell scripts.

## Requirements

### Requirement: macOS defaults declared in mise.toml

macOS user-interface and application defaults that are safe to apply declaratively SHALL be expressed in `home/private_dot_config/mise.toml` under `[bootstrap.macos.defaults.*]`, `[bootstrap.macos.dock]`, `[bootstrap.macos.finder]`, `[bootstrap.macos.keyboard]`, and `[bootstrap.macos.trackpad]` rather than duplicated in a Chezmoi defaults hook.

#### Scenario: Finder defaults applied by mise bootstrap

- **WHEN** `mise bootstrap macos defaults apply` runs on macOS
- **THEN** Finder-related defaults declared in `mise.toml` are written to the system without a Chezmoi defaults hook

#### Scenario: No duplicate defaults writes

- **WHEN** Mise bootstrap is the authoritative defaults path
- **THEN** no legacy Chezmoi defaults script executes duplicate `defaults write` operations

### Requirement: Privileged macOS setup stays explicit

macOS operations requiring `sudo` or `systemsetup`/`scutil` (hostname, remote login, timezone, Rosetta, Xcode CLT, Homebrew bootstrap) SHALL either remain in a single documented Chezmoi script or move to a named Mise task with clear privilege requirements; they SHALL NOT be silently dropped during migration.

#### Scenario: Xcode CLT and Homebrew bootstrap

- **WHEN** a fresh macOS host runs the documented bootstrap sequence
- **THEN** Xcode command-line tools and Homebrew are available before `mise bootstrap packages apply` attempts brew-managed packages

#### Scenario: Privileged steps documented

- **WHEN** a bootstrap step requires elevated privileges
- **THEN** `design.md` and `tasks.md` identify the owning tool (Chezmoi script vs Mise task) and execution order

### Requirement: macOS defaults parity check

The system SHALL document which `defaults write` / `systemsetup` calls are covered by Mise, handled by an explicit task, intentionally omitted, or deferred.

#### Scenario: Gap analysis recorded

- **WHEN** migration task 2.x completes
- **THEN** a checklist exists mapping each legacy defaults call to `mise.toml`, Chezmoi retention, or explicit non-migration
