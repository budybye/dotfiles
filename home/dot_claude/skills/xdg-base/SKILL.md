---
name: xdg-base
description: Manage and apply the XDG Base Directory specification within chezmoi dotfiles management system. Use when setting up or auditing dotfiles, configuring applications to follow XDG standards, or cleaning up home directory clutter in macOS/Ubuntu environments.
---

# XDG Base Directory Management for Chezmoi Dotfiles

This skill helps manage and apply the XDG Base Directory specification specifically within the chezmoi dotfiles management system, ensuring proper organization of application configuration, data, cache, and state files across macOS and Ubuntu environments.

## What is XDG Base Directory Specification?

The XDG Base Directory specification defines standard directories for storing application data, configuration, cache, and state files. It helps keep the user's home directory organized by moving dotfiles and application data to standardized locations.

### Key Environment Variables

| Variable | Purpose | Default Value |
|----------|---------|---------------|
| `XDG_CONFIG_HOME` | User-specific configurations | `$HOME/.config` |
| `XDG_CACHE_HOME` | Non-essential cached data | `$HOME/.cache` |
| `XDG_DATA_HOME` | User-specific data files | `$HOME/.local/share` |
| `XDG_STATE_HOME` | User-specific state files | `$HOME/.local/state` |
| `XDG_RUNTIME_DIR` | Runtime files (sockets, pipes) | Set by system |

## When to Use

- Setting up a new chezmoi dotfiles repository
- Auditing existing applications for XDG compliance
- Configuring applications to follow XDG standards within chezmoi
- Cleaning up home directory clutter in chezmoi-managed environments
- Making application data more portable across macOS and Ubuntu systems

## Quick Reference

| Task | Guide |
|------|-------|
| Check current XDG settings in chezmoi | Read [references/usage.md](references/usage.md) |
| Configure applications for XDG in chezmoi | Read [references/configuration.md](references/configuration.md) |
| Audit XDG compliance in dotfiles | Read [references/auditing.md](references/auditing.md) |
| Follow best practices for XDG in chezmoi | Read [references/best-practices.md](references/best-practices.md) |

## Chezmoi Integration Patterns

1. **Template Variables**: Use `.chezmoi.os` to handle platform differences
2. **Conditional Logic**: Apply different XDG configurations for macOS vs Ubuntu
3. **External Files**: Manage XDG-compliant applications via `.chezmoiexternal.toml`
4. **Scripts**: Use `.chezmoiscripts` to automate XDG setup

## Common Patterns in Chezmoi Context

1. **Configuration Migration**: Move `~/.appconfig` to `$XDG_CONFIG_HOME/app/config`
2. **Data Organization**: Store application data in `$XDG_DATA_HOME/app/`
3. **Cache Separation**: Keep temporary files in `$XDG_CACHE_HOME/app/`
4. **State Tracking**: Store state information in `$XDG_STATE_HOME/app/`

## Red Flags to Watch For

| Issue | Solution |
|-------|----------|
| Applications ignoring XDG variables | Use wrapper scripts or symlinks |
| Hardcoded paths in applications | Report upstream or use compatibility layers |
| Missing XDG_RUNTIME_DIR | Ensure proper login session (systemd/PAM) |
| Conflicting default values | Explicitly set variables in shell profile |
| Platform-specific differences | Use chezmoi templates with OS conditionals |

## Related Skills

- `tidy-files` - General file organization
- `dotfiles-management` - Dotfiles repository maintenance
- `environment-variables` - Shell environment configuration
- `chezmoi-best-practices` - Chezmoi-specific guidelines