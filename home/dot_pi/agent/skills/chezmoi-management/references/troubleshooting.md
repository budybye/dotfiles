# Troubleshooting Guide

## Common Issues and Solutions

### Excessive `DA` Entries in `chezmoi status` (e.g., `node_modules/`)

Add patterns to `.chezmoiignore`:

```
node_modules
**/.DS_Store
```

### Resolving Source/Destination Conflicts

```bash
chezmoi merge ~/.zshrc          # Three-way merge (vimdiff-style)
chezmoi forget ~/.something     # Remove from source (preserve destination)
chezmoi destroy ~/.something    # Delete from both (destructive)
```

Merge tools are configured in the `[merge]` section of `~/.config/chezmoi/chezmoi.toml`:

```toml
[merge]
  command = "nvim"
  args = ["-d", "{{ .Destination }}", "{{ .Source }}", "{{ .Target }}"]
```

If unset, it uses `git config merge.tool`. If neither is configured, falls back to vimdiff.

### Reverting Problematic Changes

Chezmoi has no built-in undo. Revert using git in the source directory:

```bash
chezmoi cd
git log --oneline -5
git reset --hard <commit-hash>
cd -
chezmoi apply
```

### Identifying Managed Files

```bash
chezmoi managed                 # List all managed files
chezmoi unmanaged ~/            # Find unmanaged files
chezmoi managed ~/.pi           # Filter by path
```

### Performance Optimization

The `run_after_apm-install.sh` script executes `apm install` on every apply. To skip when no skill updates are needed:

```bash
SKIP_APM=1 chezmoi apply    # Only works if script supports this flag
```

If unsupported, the flag is simply ignored.