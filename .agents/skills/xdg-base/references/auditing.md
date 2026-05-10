# XDG Compliance Auditing in Chezmoi Environment

## Identifying Non-XDG Compliant Applications

### Method 1: File Monitoring in Chezmoi Context
Monitor file creation to identify where applications store data in your chezmoi-managed environment:

```bash
# Using inotify (Linux)
inotifywait -m -r -e create "$HOME" --exclude "($XDG_CONFIG_HOME|$XDG_CACHE_HOME|$XDG_DATA_HOME|$XDG_STATE_HOME)" &

# Using fs_usage (macOS)
sudo fs_usage -w -f filesys | grep "$HOME" | grep -v -E "($XDG_CONFIG_HOME|$XDG_CACHE_HOME|$XDG_DATA_HOME|$XDG_STATE_HOME)"
```

### Method 2: Home Directory Analysis in Chezmoi
Scan for dotfiles and directories that should be moved in your chezmoi setup:

```bash
# List top-level dotfiles
find "$HOME"/.* -maxdepth 0 -type f,l 2>/dev/null | head -20

# List top-level dotdirectories
find "$HOME"/.* -maxdepth 0 -type d 2>/dev/null | grep -v -E "\.$|..$" | head -20

# Analyze directory sizes
du -sh "$HOME"/.* 2>/dev/null | sort -hr | head -20
```

### Method 3: Process Monitoring
Check what files applications access during runtime:

```bash
# Using strace (Linux)
strace -e trace=openat,open -f application 2>&1 | grep "$HOME"

# Using dtrace (macOS)
sudo dtrace -n 'syscall::open*:entry /pid == $target/ { printf("%s", copyinstr(arg0)); }' -c "application"
```

## Chezmoi-Specific Auditing Approach

### Unmanaged Files Detection
Use chezmoi to identify files not managed by your dotfiles:

```bash
# Find unmanaged dotfiles
chezmoi unmanaged ~

# Focus on configuration files
chezmoi unmanaged ~/.config/

# Focus on cache files (may be intentionally unmanaged)
chezmoi unmanaged ~/.cache/
```

### Template Verification
Verify that your chezmoi templates are generating correct XDG paths:

```bash
# Check generated files
chezmoi diff

# Execute templates to verify output
chezmoi execute-template < template_file.tmpl
```

## Classification Framework for Chezmoi

### Category A: Fully XDG-Compliant
Applications that respect all XDG environment variables without additional configuration in your chezmoi setup.

### Category B: Configurable XDG Support
Applications that can be made XDG-compliant through configuration files managed by chezmoi.

### Category C: Partial XDG Support
Applications that respect some XDG variables but not others in your chezmoi environment.

### Category D: No XDG Support
Applications that hardcode paths and ignore XDG variables entirely, requiring workarounds in your chezmoi setup.

## Remediation Strategies in Chezmoi Context

### For Category B Applications
1. Check application documentation for XDG configuration options
2. Set appropriate environment variables in your chezmoi templates
3. Modify application configuration files managed by chezmoi

### For Category C Applications
1. Use symbolic links managed by chezmoi to redirect hardcoded paths
2. Create wrapper scripts in `home/dot_local/bin/executable_*`
3. Patch application configuration if possible through chezmoi templates

### For Category D Applications
1. Submit feature requests to upstream developers
2. Use compatibility layers or wrappers managed by chezmoi
3. Consider alternative applications with better XDG support

## Reporting Format for Chezmoi Audits

When auditing applications in your chezmoi environment, document findings in this format:

```
Application: [Name]
Version: [Version if available]
XDG Status: [Category A/B/C/D]
Issues Found:
- [List specific XDG variables not respected]
- [List hardcoded paths used]
Chezmoi Solutions:
- [Specific steps to improve XDG compliance using chezmoi]
- [Template examples or external file configurations]
```

## Automation Tools for Chezmoi

### Simple Dotfile Detector
Create a script in `home/dot_local/bin/executable_detect_non_xdg`:

```bash
#!/bin/bash
# Detect potential dotfiles to migrate in chezmoi context
for item in "$HOME"/.*; do
    [[ -f "$item" || -d "$item" ]] || continue
    basename_item=$(basename "$item")
    [[ "$basename_item" == "." || "$basename_item" == ".." ]] && continue
    
    # Skip already XDG-compliant directories
    case "$basename_item" in
        .config|.cache|.local) continue ;;
    esac
    
    # Check if managed by chezmoi
    if chezmoi managed | grep -q "$basename_item"; then
        status="managed"
    else
        status="unmanaged"
    fi
    
    echo "Potential migration candidate: $basename_item ($status)"
done
```

### XDG Compliance Checker for Chezmoi
Create a script in `home/dot_local/bin/executable_check_xdg`:

```bash
#!/bin/bash
# XDG environment checker for chezmoi context
required_vars=(XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME)
all_set=true

echo "XDG Base Directory Compliance Check"
echo "==================================="

for var in "${required_vars[@]}"; do
    if [[ -z "${!var}" ]]; then
        echo "WARNING: $var is not set"
        all_set=false
    else
        echo "$var: ${!var}"
        
        # Check if directory exists
        if [[ ! -d "${!var}" ]]; then
            echo "  WARNING: Directory does not exist"
        fi
    fi
done

if [[ "$all_set" == true ]]; then
    echo "All XDG variables are properly set"
fi

# Platform-specific checks
if [[ "$(uname)" == "Darwin" ]]; then
    echo "Platform: macOS"
    echo "Note: Consider using Library directories for better macOS integration"
elif [[ "$(uname)" == "Linux" ]]; then
    echo "Platform: Linux"
    if [[ -z "$XDG_RUNTIME_DIR" ]]; then
        echo "WARNING: XDG_RUNTIME_DIR is not set"
    else
        echo "XDG_RUNTIME_DIR: $XDG_RUNTIME_DIR"
    fi
fi
```

## Chezmoi Integration Best Practices

### Template Variables for Platform Differences
Use chezmoi's built-in template variables to handle platform differences:

```go
{{- if eq .chezmoi.os "darwin" }}
# macOS-specific XDG handling
{{- else if eq .chezmoi.os "linux" }}
# Linux-specific XDG handling
{{- end }}
```

### External File Management for XDG Data
Use `.chezmoiexternal.toml` to manage XDG-compliant application data:

```toml
[".local/share/app-data"]
    type = "archive"
    url = "https://example.com/app-data.tar.gz"
    refreshPeriod = "168h"
```

### Script-Based Setup
Use `.chezmoiscripts` to automate XDG directory creation and verification:

```bash
# .chezmoiscripts/run_onchange_after_xdg_setup.sh
#!/bin/bash
# Ensure XDG directories exist with proper permissions
mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"
chmod 700 "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" 2>/dev/null || true
chmod 755 "$XDG_CACHE_HOME" 2>/dev/null || true
```