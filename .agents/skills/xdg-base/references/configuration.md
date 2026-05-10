# XDG Application Configuration in Chezmoi

## Making Applications XDG-Compliant in Chezmoi

### Method 1: Native Support
Many modern applications already support XDG. Simply ensure the environment variables are set correctly in your chezmoi dotfiles.

### Method 2: Configuration Files
Some applications can be directed to use XDG directories through their configuration files managed by chezmoi:

Example for Node.js applications (`home/private_dot_config/npm/config`):
```
prefix=${XDG_DATA_HOME}/npm
cache=${XDG_CACHE_HOME}/npm
tmp=${XDG_RUNTIME_DIR}/npm
```

Example for Python applications (setting in environment in chezmoi templates):
```bash
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME/python"
```

### Method 3: Wrapper Scripts in Chezmoi
Create wrapper scripts for applications that hardcode paths, placed in `home/dot_local/bin/executable_*`:

```bash
#!/bin/bash
# Wrapper for application that uses ~/.myapp
export HOME="$XDG_CONFIG_HOME/myapp"
exec /usr/bin/myapp "$@"
```

### Method 4: Symbolic Links in Chezmoi
Use chezmoi to manage symbolic links that redirect legacy paths to XDG locations:

In `home/.chezmoiexternal.toml.tmpl`:
```toml
{{- if eq .chezmoi.os "darwin" }}
[".bash_history"]
    type = "symlink"
    target = "{{ .chezmoi.homeDir }}/.local/state/bash/history"
{{- end }}
```

## Common Application Migrations in Chezmoi Context

### Bash History
In `home/dot_zshenv.tmpl`:
```bash
export HISTFILE="$XDG_STATE_HOME/bash/history"
mkdir -p "$(dirname "$HISTFILE")" 2>/dev/null || true
```

### Less History
In environment templates:
```bash
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"
mkdir -p "$(dirname "$LESSHISTFILE")" 2>/dev/null || true
```

### Node.js
In environment templates:
```bash
export NODE_REPL_HISTORY="$XDG_STATE_HOME/nodejs/repl_history"
mkdir -p "$(dirname "$NODE_REPL_HISTORY")" 2>/dev/null || true
```

### MySQL Client
In environment templates:
```bash
export MYSQL_HISTFILE="$XDG_STATE_HOME/mysql/history"
```

### Rust/Cargo
In `home/private_dot_config/cargo/config.toml`:
```toml
[net]
git-fetch-with-cli = true

[env]
CARGO_HOME = { value = "$XDG_DATA_HOME/cargo", force = true }
```

## Directory Structure Recommendations for Chezmoi

Organize XDG directories with application grouping in your chezmoi structure:

```
home/
├── private_dot_config/
│   ├── app1/
│   ├── app2/
│   └── shared/
├── dot_local/
│   └── share/  # XDG_DATA_HOME
│       ├── app1/
│       └── app2/
└── dot_cache/  # XDG_CACHE_HOME
    ├── app1/
    └── app2/
```

## Chezmoi Template Examples

### Conditional XDG Setup
In `home/dot_profile.tmpl`:
```bash
{{- if eq .chezmoi.os "darwin" }}
# macOS specific XDG setup
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/Library/Caches}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/Library/Application Support}"
{{- else }}
# Linux XDG setup
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
{{- end }}
```

### Application-Specific Templates
In `home/private_dot_config/git/config.tmpl`:
```ini
[core]
  editor = nvim
[commit]
  template = {{ .chezmoi.homeDir }}/.config/git/commit.template
[gpg]
  program = gpg
```

## External File Management
In `home/.chezmoiexternal.toml.tmpl`:
```toml
# XDG-compliant application data
[".local/share/myapp"]
    type = "archive"
    url = "https://example.com/myapp-data.tar.gz"
    exact = true
    stripComponents = 1
    refreshPeriod = "168h"
```