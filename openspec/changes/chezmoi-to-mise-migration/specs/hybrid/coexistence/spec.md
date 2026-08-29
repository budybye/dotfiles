## Purpose

Defines how Chezmoi and Mise coexist during phased migration without breaking cross-platform dotfile deployment, secrets handling, or multi-GitHub-account SSH workflows.

## ADDED Requirements

### Requirement: Clear responsibility split

During and after phase-1 migration, Chezmoi SHALL remain authoritative for templated config file deployment, age-encrypted secrets, host/user branching in `.chezmoi.toml.tmpl`, SSH multi-account setup, VS Code extension installation, external archive fetching, and agent-skills installation. Mise SHALL be authoritative for tool versions (`mise.toml` `[tools]`), OS package bootstrap (`[bootstrap.packages]`), and macOS declarative defaults (`[bootstrap.macos.*]`).

#### Scenario: Config file still managed by chezmoi

- **WHEN** `chezmoi apply` runs after phase-1 migration
- **THEN** symlinked config files under `home/` continue to deploy with Go-template branching unchanged

#### Scenario: Tools managed by mise

- **WHEN** a developer runs `mise install` or opens a new shell with mise activated
- **THEN** tool versions from `home/private_dot_config/mise/config.toml` are available without Chezmoi re-applying package install scripts

### Requirement: Documented bootstrap ordering

The repository SHALL document a recommended apply order for new machines: Chezmoi bootstrap prerequisites (mise binary, age/bitwarden if needed) → `mise bootstrap` (packages, macOS defaults) → `chezmoi apply` (configs, remaining scripts).

#### Scenario: Fresh macOS setup

- **WHEN** a user follows the documented setup guide on a new Mac
- **THEN** each step's tool owner (Chezmoi vs Mise) is unambiguous and re-running a step is idempotent

### Requirement: Multi-GitHub-account SSH preserved

Multi-account GitHub access via per-user SSH `Host` aliases (as implemented in `run_once_after_ssh.sh.tmpl`) SHALL remain under Chezmoi management in phase 1 and SHALL NOT be migrated to Mise `[dotfiles]` until a templating strategy for multiple identities is designed and tested.

#### Scenario: Second GitHub identity

- **WHEN** `chezmoi apply` runs for a host configured with a non-default `name` / username mapping in `.chezmoi.toml.tmpl`
- **THEN** SSH config receives the correct `Host <username>` block pointing at `github.com` with the matching `IdentityFile`

#### Scenario: Mise bootstrap does not overwrite SSH config

- **WHEN** `mise bootstrap` runs on a host with Chezmoi-managed `~/.ssh/config`
- **THEN** no Mise `[dotfiles]` entry overwrites or truncates existing SSH configuration during phase 1

### Requirement: Cross-platform matrix maintained

The migration SHALL preserve behavior on macOS, Linux, and Windows targets defined by the existing Chezmoi layout. Platform-specific install logic moved to Mise MUST be guarded so it only runs on supported OS targets; unsupported platforms keep existing Chezmoi scripts until covered.

#### Scenario: Linux GUI packages

- **WHEN** `mise bootstrap packages apply` runs on Linux
- **THEN** only apt-declared packages are managed by Mise; snap and one-shot Linux setup scripts continue via Chezmoi where not yet migrated

#### Scenario: Windows unchanged in phase 1

- **WHEN** `chezmoi apply` runs on Windows
- **THEN** `run_once_after_install.ps1.tmpl` behavior is unchanged and no macOS/Linux-only Mise bootstrap steps are invoked

### Requirement: CI and container environments skip host bootstrap

In CI, Codespaces, Remote Containers, Docker, and sandbox environments detected by `.chezmoi.toml.tmpl`, secret-dependent and heavy bootstrap steps SHALL remain disabled as today; Mise bootstrap package steps SHALL NOT assume interactive sudo or GUI availability in those environments.

#### Scenario: GitHub Actions runner

- **WHEN** `GITHUB_ACTIONS=true` and `chezmoi apply` runs
- **THEN** age/bitwarden decryption and personal macOS defaults are skipped, matching current template guards
