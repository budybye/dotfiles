## Purpose

Captures the still-correct chezmoi source-tree and XDG placement rules from `directory.md`, and drops descriptions that no longer match the repository.

## ADDED Requirements

### Requirement: Source tree follows chezmoi prefixes
Managed home files MUST keep chezmoi naming prefixes (`dot_`, `private_`, `executable_`, `encrypted_`) and MUST stay under `home/`. Layout rules that contradict the live tree MUST be treated as false and omitted from the spec.

#### Scenario: Adding a managed file
- **WHEN** a new file is added to the source tree
- **THEN** it MUST use the chezmoi prefix that matches its destination and sensitivity
- **AND** it MUST NOT be documented as living under a path that does not exist

### Requirement: OS-specific scripts stay split
Darwin and Linux scripts MUST remain in `home/.chezmoiscripts/darwin/` and `home/.chezmoiscripts/linux/` respectively. Shared scripts MUST stay at `home/.chezmoiscripts/` root.

#### Scenario: Linux GUI hook
- **WHEN** a Linux-only GUI bootstrap script is added
- **THEN** it MUST live under `home/.chezmoiscripts/linux/`
- **AND** it MUST NOT run on darwin
