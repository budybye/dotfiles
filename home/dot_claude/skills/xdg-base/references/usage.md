# XDG Base Directory Usage Guide for Chezmoi

## Checking Current Settings in Chezmoi Environment

To check your current XDG environment variables in a chezmoi-managed environment:

```bash
env | grep XDG_
```

To see the effective values (including defaults):

```bash
echo "XDG_CONFIG_HOME: ${XDG_CONFIG_HOME:-$HOME/.config}"
echo "XDG_CACHE_HOME: ${XDG_CACHE_HOME:-$HOME/.cache}"
echo "XDG_DATA_HOME: ${XDG_DATA_HOME:-$HOME/.local/share}"
echo "XDG_STATE_HOME: ${XDG_STATE_HOME:-$HOME/.local/state}"
```

## Setting Up XDG Variables in Chezmoi

In your chezmoi dotfiles, add to your shell profile template (`home/dot_zshenv.tmpl` or `home/private_dot_config/zsh/dot_zshenv.tmpl`):

```bash
{{ if eq .chezmoi.os "darwin" }}
# macOS specific XDG settings
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/Library/Caches"
export XDG_DATA_HOME="$HOME/Library/Application Support"
{{ else if eq .chezmoi.os "linux" }}
# Linux/Ubuntu specific XDG settings
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
{{ end }}

# Common settings
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
```

## Verifying Setup in Chezmoi

Add a verification script in `.chezmoiscripts/run_onchange_after_xdg_check.sh.tmpl`:

```bash
#!/bin/bash
# Verify XDG directory setup

echo "Verifying XDG directory setup..."

# Create directories if they don't exist
mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" 2>/dev/null || true

# Check permissions
if [ -n "$XDG_RUNTIME_DIR" ] && [ -d "$XDG_RUNTIME_DIR" ]; then
    chmod 700 "$XDG_RUNTIME_DIR" 2>/dev/null || true
fi

echo "XDG directories verified:"
echo "  XDG_CONFIG_HOME: $XDG_CONFIG_HOME"
echo "  XDG_CACHE_HOME: $XDG_CACHE_HOME"
echo "  XDG_DATA_HOME: $XDG_DATA_HOME"
echo "  XDG_STATE_HOME: $XDG_STATE_HOME"
{{ if eq .chezmoi.os "linux" }}
echo "  XDG_RUNTIME_DIR: $XDG_RUNTIME_DIR"
{{ end }}
```

## Testing Applications in Chezmoi Context

To test if an application respects XDG variables in your chezmoi environment:

1. Set up a custom XDG environment:
   ```bash
   export XDG_CONFIG_HOME="/tmp/test-config"
   export XDG_DATA_HOME="/tmp/test-data"
   mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME"
   ```

2. Run the application and check where it creates files

3. Clean up:
   ```bash
   rm -rf "/tmp/test-config" "/tmp/test-data"
   ```

## Chezmoi Template Integration

Use chezmoi templates to handle platform differences:

```go
# In home/dot_profile.tmpl or similar
{{- if eq .chezmoi.os "darwin" }}
# macOS XDG Base Directory compatibility
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/Library/Caches}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/Library/Application Support}"
{{- else if eq .chezmoi.os "linux" }}
# Standard XDG Base Directory specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
{{- end }}
```