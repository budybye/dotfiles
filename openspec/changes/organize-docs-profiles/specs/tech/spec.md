## Purpose

States which files are the source of truth for the installed stack, so markdown cannot drift away from mise, aqua, and `packages.yaml`.

## ADDED Requirements

### Requirement: Package source of truth
The installed tool set MUST be defined by `home/private_dot_config/mise/config.toml`, `home/.chezmoidata/packages.yaml`, and `home/private_dot_config/aquaproj-aqua/aqua.yaml`. Specs and README MAY name those files. They MUST NOT duplicate full package lists.

#### Scenario: Stack question
- **WHEN** a reader asks which CLI tools this machine installs
- **THEN** the answer MUST come from those three files
- **AND** a markdown copy of the list MUST NOT be treated as authoritative

### Requirement: Supported platforms
The system MUST support macOS and Ubuntu. Windows package keys MAY exist as partial support. Docker / Dev Container / Multipass remain valid apply targets.

#### Scenario: Ubuntu apply
- **WHEN** chezmoi apply runs on Ubuntu
- **THEN** Linux package keys MUST be the ones considered
- **AND** darwin casks MUST NOT be required
