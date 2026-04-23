# XDG Base Directory Best Practices for Chezmoi

## Core Principles

### 1. Consistency Across Platforms
Maintain consistent XDG usage across macOS and Ubuntu while respecting platform conventions:

```go
# In chezmoi templates
{{- if eq .chezmoi.os "darwin" }}
# macOS: Prefer Library directories for better integration
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/Library/Caches}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/Library/Application Support}"
{{- else if eq .chezmoi.os "linux" }}
# Linux: Follow standard XDG specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
{{- end }}
```

### 2. Progressive Enhancement
Start with basic XDG support and gradually enhance:

1. **Level 1**: Set basic environment variables
2. **Level 2**: Configure applications to use XDG directories
3. **Level 3**: Migrate existing data to XDG locations
4. **Level 4**: Automate maintenance and verification

### 3. Backward Compatibility
Ensure existing configurations continue to work:

```bash
# In migration scripts
if [ -f "$HOME/.myapp/config" ] && [ ! -f "$XDG_CONFIG_HOME/myapp/config" ]; then
    mkdir -p "$XDG_CONFIG_HOME/myapp"
    mv "$HOME/.myapp/config" "$XDG_CONFIG_HOME/myapp/config"
    ln -sf "$XDG_CONFIG_HOME/myapp/config" "$HOME/.myapp/config"
fi
```

## Chezmoi Integration Patterns

### Pattern 1: Template-Based Configuration
Use chezmoi templates to handle platform differences:

```go
# In home/dot_profile.tmpl
{{- if ne .chezmoi.os "windows" }}
# XDG Base Directory setup
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
{{- if eq .chezmoi.os "darwin" }}
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/Library/Caches}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/Library/Application Support}"
{{- else }}
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
{{- end }}
{{- end }}
```

### Pattern 2: Script-Based Automation
Use chezmoi scripts for complex setup tasks:

```bash
# .chezmoiscripts/run_onchange_after_xdg_setup.sh.tmpl
#!/usr/bin/env bash
{{- if ne .chezmoi.os "windows" }}

set -euo pipefail

# Ensure XDG directories exist
mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME"
{{- if ne .chezmoi.os "darwin" }}
mkdir -p "$XDG_STATE_HOME"
{{- end }}

# Set appropriate permissions
chmod 700 "$XDG_CONFIG_HOME" 2>/dev/null || true
{{- if ne .chezmoi.os "darwin" }}
chmod 700 "$XDG_DATA_HOME" "$XDG_STATE_HOME" 2>/dev/null || true
{{- end }}
chmod 755 "$XDG_CACHE_HOME" 2>/dev/null || true

echo "XDG directories initialized successfully"
{{- end }}
```

### Pattern 3: External File Management
Use `.chezmoiexternal.toml` for XDG-compliant data:

```toml
# .chezmoiexternal.toml.tmpl
{{- if ne .chezmoi.os "windows" }}
[".local/share/app-icons"]
    type = "archive"
    url = "https://example.com/icons.tar.gz"
    exact = true
    stripComponents = 1
    refreshPeriod = "168h"
{{- end }}
```

## Security Considerations

### Directory Permissions
Set appropriate permissions for XDG directories:

```bash
# Configuration directory (private)
chmod 700 "$XDG_CONFIG_HOME"

# Data directory (private)
chmod 700 "$XDG_DATA_HOME"

# State directory (private)
chmod 700 "$XDG_STATE_HOME"

# Cache directory (shared read access)
chmod 755 "$XDG_CACHE_HOME"
```

### Sensitive Data Handling
Separate sensitive data from regular XDG directories:

```bash
# Use separate encrypted storage for sensitive data
export SECRET_DATA_HOME="$HOME/.local/secrets"
# This directory should be managed separately with encryption
```

## Performance Optimization

### Cache Directory Management
Implement cache cleanup policies:

```bash
# Add to periodic cleanup script
find "$XDG_CACHE_HOME" -type f -atime +30 -delete
find "$XDG_CACHE_HOME" -type d -empty -delete
```

### State Directory Rotation
Implement log rotation for state files:

```bash
# In application configuration
export APP_LOG_FILE="$XDG_STATE_HOME/myapp/log.txt"
# Implement log rotation in application or via logrotate
```

## Troubleshooting Guide

### Common Issues and Solutions

#### Issue 1: Applications Ignore XDG Variables
**Solution**: Use wrapper scripts or configuration files
```bash
# Create wrapper in home/dot_local/bin/executable_appname
#!/bin/bash
export HOME="$XDG_CONFIG_HOME/appname"
exec /usr/bin/original-app "$@"
```

#### Issue 2: Missing XDG_RUNTIME_DIR on macOS
**Solution**: Set fallback in shell profile
```bash
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-$(id -u)}"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"
```

#### Issue 3: Permission Errors
**Solution**: Verify directory permissions
```bash
# Check and fix permissions
chmod 700 "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" 2>/dev/null || true
chmod 755 "$XDG_CACHE_HOME" 2>/dev/null || true
```

## Maintenance Best Practices

### Regular Audits
Schedule regular XDG compliance audits:

```bash
# Monthly audit script
chezmoi unmanaged ~ | grep '^\.'
# Review and migrate any new dotfiles
```

### Backup Strategy
Include XDG directories in backup plans:

```bash
# In backup script
backup_dirs=(
    "$XDG_CONFIG_HOME"
    "$XDG_DATA_HOME"
    "$XDG_STATE_HOME"
)
# Exclude cache directory from backups
```

### Documentation
Document XDG customizations in your chezmoi repository:

```markdown
# XDG Customizations

This repository implements the XDG Base Directory specification with the following customizations:

- Uses Library directories on macOS for better integration
- Maintains separate state directory on Linux
- Implements automatic migration of legacy dotfiles
```

## Advanced Techniques

### Conditional XDG Setup
Handle different environments with chezmoi templates:

```go
{{- if env "WORK_ENVIRONMENT" }}
# Work-specific XDG setup
export XDG_CONFIG_HOME="$HOME/.config/work"
{{- else }}
# Personal XDG setup
export XDG_CONFIG_HOME="$HOME/.config"
{{- end }}
```

### Application-Specific Overrides
Override XDG for specific applications:

```bash
# In application wrapper or configuration
export MYAPP_CONFIG_DIR="$XDG_CONFIG_HOME/myapp-enterprise"
```

### Container Integration
Use XDG directories with containerized applications:

```bash
# Docker run with XDG volume mounts
docker run -v "$XDG_CONFIG_HOME/myapp:/root/.config/myapp" myapp
```

## Future-Proofing

### Stay Updated
Monitor XDG specification updates:
- Subscribe to freedesktop.org announcements
- Follow XDG-related discussions in developer communities
- Regularly review application XDG compliance

### Community Contributions
Contribute to XDG adoption:
- Submit patches to applications that don't support XDG
- Share configurations and migration guides
- Participate in specification discussions

This best practices guide ensures robust, maintainable XDG implementation within your chezmoi dotfiles management system.