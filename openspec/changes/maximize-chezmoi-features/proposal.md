## Why

Chezmoi is already the repository's configuration source of truth, but several capabilities are only partially used or documented. This change makes platform branching, templates and data, lifecycle scripts, file attributes, secrets, external resources, and safe validation work as one predictable workflow instead of ad hoc per-file conventions.

## What Changes

- Establish a supported Chezmoi workflow for preview, apply, verification, and rollback-sensitive changes.
- Use templates, `.chezmoiignore`, `.chezmoitemplates`, and `.chezmoidata` for OS, host, and environment differences instead of duplicated files.
- Standardize lifecycle scripts for dependency/bootstrap ordering and idempotent execution.
- Apply the full native attribute model: `dot_`, `private_`, `encrypted_`, `executable_`, `symlink_`, `readonly_`, `create_`, `modify_`, `remove_`, `empty_`, `exact_`, `once_`, `onchange_`, `before_`, and `after_` where appropriate.
- Define safe handling for secrets, external resources, and generated files.
- Add repository-level validation for template rendering, script syntax, permissions, platform selection, and required dependencies.
- Document migration rules for existing files and reject ambiguous or duplicate configuration sources.
- Use the reference patterns from `twpayne/dotfiles` and the official Chezmoi source/documentation as design input.

## Capabilities

### New Capabilities

- `chezmoi-feature-utilization`: Consistent use of Chezmoi templates, data, scripts, file attributes, secrets, externals, platform branching, and validation.

### Modified Capabilities

<!-- No existing OpenSpec capabilities exist yet. -->

## Impact

- `home/.chezmoi.toml.tmpl`
- `home/.chezmoidata/`
- `home/.chezmoiscripts/`
- `home/.chezmoiexternal.toml.tmpl`
- `home/.chezmoiignore`
- `home/` file attribute prefixes and platform-specific layouts
- Reference repositories:
  - `https://github.com/twpayne/dotfiles`
  - `https://github.com/twpayne/chezmoi`
- No new runtime dependency intended; existing Chezmoi, shellcheck, and platform tools remain the baseline.
