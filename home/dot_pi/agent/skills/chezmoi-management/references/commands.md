# Chezmoi Commands Reference

## Daily Workflow Commands

### Check Differences
```bash
chezmoi diff                   # Compare source and destination
chezmoi status                 # General status (MM/M /?? etc.)
```

### Understanding `chezmoi diff` Output
- `-` lines = content in destination (current files) — will be **removed** on apply
- `+` lines = content in target (expected state after template expansion) — will be **added** on apply
- `chezmoi apply` aligns destination with target (source → destination)

### Import Changes from Destination to Source
```bash
chezmoi add ~/.zshrc                    # Add new files
chezmoi re-add                          # Bulk import changes to managed files
chezmoi re-add ~/.pi/CLAUDE.md          # Individual file update
```

### Apply Changes from Source to Destination
```bash
chezmoi diff                            # Preview changes first
chezmoi apply                           # Apply all changes
chezmoi apply ~/.pi/CLAUDE.md           # Apply specific file
chezmoi apply --verbose                 # Show detailed execution
```

### Edit Source Files
```bash
chezmoi edit ~/.zshrc                   # Edit source file (apply after editor closes?)
chezmoi edit -a ~/.zshrc                # Edit then automatically apply
chezmoi edit ~/.pi/CLAUDE.md            # Edit pi configuration
chezmoi cd                              # Change to source directory
```

## New Machine Initialization

```bash
# Install chezmoi first: brew install chezmoi etc.

chezmoi init https://github.com/hotmilk/chezmoi-dotfiles.git --apply
# Clones and applies. run_after_apm-install.sh executes
# apm install --global --target claude to install external skills

# Enable pre-commit (one-time setup on new machines)
cd $(chezmoi source-path)
prek install
```