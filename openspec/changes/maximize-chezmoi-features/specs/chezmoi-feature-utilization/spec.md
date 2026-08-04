## Purpose

Provide one predictable, platform-aware Chezmoi workflow that safely renders, installs, validates, and maintains all managed dotfiles without duplicated configuration or accidental secret exposure.

## ADDED Requirements

### Requirement: Platform-specific configuration SHALL render from shared data

The managed configuration SHALL use one shared source with explicit platform, host, and environment data. Applying the source on a supported platform SHALL render only values and files intended for that platform.

#### Scenario: macOS application
- **WHEN** the source is applied on macOS
- **THEN** macOS-specific configuration and scripts are rendered, and Linux-only configuration is not installed

#### Scenario: Linux application
- **WHEN** the source is applied on Linux
- **THEN** Linux-specific configuration and scripts are rendered, and macOS-only configuration is not installed

### Requirement: Managed file attributes SHALL preserve intended local behavior

Managed files SHALL retain their declared dotfile name, executable permission, private permission, read-only state, symlink target, or encrypted state after application. Attributes SHALL NOT be encoded only in undocumented manual steps.

#### Scenario: Executable helper installation
- **WHEN** Chezmoi applies an executable helper
- **THEN** the installed helper is available at its target path with execute permission

#### Scenario: Private or encrypted file installation
- **WHEN** Chezmoi applies a private or encrypted file
- **THEN** the resulting file is installed with restricted access and plaintext secret content is not committed to the source tree

### Requirement: Lifecycle automation SHALL be ordered and repeatable

Lifecycle scripts SHALL declare their execution phase through Chezmoi naming conventions, complete successfully when run more than once, and avoid duplicating packages, files, services, or configuration on repeated application.

#### Scenario: First application
- **WHEN** a user applies the source on a supported host for the first time
- **THEN** prerequisite setup runs before dependent configuration and the resulting environment is usable

#### Scenario: Repeated application
- **WHEN** a user applies the unchanged source again
- **THEN** no duplicate resources are created and no avoidable destructive change occurs

### Requirement: Secrets and external resources SHALL remain out of ordinary source files

Secrets SHALL use the repository's encrypted or secret-manager flow, and external resources SHALL be declared separately from ordinary managed file content. Application SHALL fail clearly when a required secret or external resource cannot be resolved.

#### Scenario: Secret unavailable
- **WHEN** a required secret cannot be obtained during application
- **THEN** the operation reports the missing prerequisite and does not install a misleading incomplete secret-dependent configuration

#### Scenario: External resource unavailable
- **WHEN** a declared external resource cannot be downloaded or verified
- **THEN** the operation reports the resource failure and preserves the previous usable local state when possible

### Requirement: Changes SHALL be previewable and validated before broad application

The repository SHALL provide a repeatable validation path that checks rendered templates, shell syntax, file attributes, platform selection, and required dependencies before changes are applied across a host fleet or CI environment.

#### Scenario: Invalid template
- **WHEN** a template contains an unresolved variable or invalid rendering expression
- **THEN** validation fails before managed files are changed

#### Scenario: Invalid executable script
- **WHEN** a managed shell helper contains a syntax or static-analysis error
- **THEN** validation reports the file and failure before release or application

#### Scenario: Preview with no changes
- **WHEN** a user requests a preview of pending changes
- **THEN** the workflow reports the files and permissions that would change without modifying the target home directory
