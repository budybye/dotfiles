# coexistence Specification

## Purpose

Defines how Chezmoi and Mise coexist during phased migration without breaking cross-platform dotfile deployment, secrets handling, or multi-GitHub-account SSH workflows.

## Requirements

### Requirement: Clear responsibility split

During and after phase-1 migration, Chezmoi SHALL remain authoritative for templated config file deployment, age-encrypted secrets, host/user branching in `.chezmoi.toml.tmpl`, encrypted SSH files and SSH config templates, VS Code extension installation, external archive fetching, and agent-skills installation. Optional local key generation and permission repair SHALL be provided by the explicit `ssh_setup` command, not by a Chezmoi lifecycle hook. Mise SHALL be authoritative for tool versions (`mise.toml` `[tools]`), OS package bootstrap (`[bootstrap.packages]`), and macOS declarative defaults (`[bootstrap.macos.*]`).

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

### Requirement: Explicit non-destructive SSH setup

SSH key generation SHALL be explicit through `ssh_setup --generate`. The command SHALL preserve existing private keys, avoid modifying Chezmoi-managed SSH config and `authorized_keys`, and set only required permissions on existing SSH files.

#### Scenario: Chezmoi apply does not generate SSH keys

- **WHEN** `chezmoi apply` runs
- **THEN** no SSH key is generated, replaced, or appended to `authorized_keys`

#### Scenario: Explicit SSH key generation

- **WHEN** a user runs `ssh_setup --generate` and the configured private key is missing
- **THEN** an Ed25519 key is generated without overwriting an existing file, and the SSH directory/key permissions are set

#### Scenario: Existing SSH key is preserved

- **WHEN** a user runs `ssh_setup` with an existing private key
- **THEN** the private key content remains unchanged and Chezmoi-managed config files are not modified

### Requirement: Mise bootstrap does not overwrite SSH config

Mise bootstrap SHALL NOT overwrite or truncate Chezmoi-managed SSH configuration.

#### Scenario: Mise bootstrap preserves SSH config

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
