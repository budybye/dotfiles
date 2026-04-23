# Troubleshooting Guide

## Common Issues and Solutions

### `chezmoi status` shows lots of `DA` entries (`node_modules/`, etc.)

Add to `.chezmoiignore`:

```
node_modules
**/.DS_Store
```

### Source and dest are conflicting

```bash
chezmoi merge ~/.zshrc          # 3-way merge (vimdiff-like)
chezmoi forget ~/.something     # Remove from source (keep dest)
chezmoi destroy ~/.something    # Delete both (destructive)
```

The merge backend is specified in the `[merge]` section of `~/.config/chezmoi/chezmoi.toml`:

```toml
[merge]
  command = "nvim"
  args = ["-d", "{{ .Destination }}", "{{ .Source }}", "{{ .Target }}"]
```

If not set, it refers to `git config merge.tool`. If neither is set, it falls back to vimdiff.

### Applied changes broke something → Revert to previous revision

Chezmoi has no undo. Revert using git on the source side:

```bash
chezmoi cd
git log --oneline -5
git reset --hard <rev>
cd -
chezmoi apply
```

### Which files are managed?

```bash
chezmoi managed                 # List of managed files
chezmoi unmanaged ~/            # Unmanaged files
chezmoi managed ~/.pi           # Filter by path
```

### Apply is slow

The `run_after_apm-install.sh` `apm install` runs every time. If there are no skill updates, skip during apply with environment variable:

```bash
SKIP_APM=1 chezmoi apply    # Only works if the script supports it
```

If not supported, ignore.