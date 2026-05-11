---
name: dotfiles
description: "Single entry for chezmoi-managed home layouts and XDG roles: bootstrap/sync, track vs refresh-from-disk, naming in source trees. macOS/Ubuntu. [Triggers: dotfiles, chezmoi, XDG, new machine]"
---

# Dotfiles

**Separation of roles** (what belongs where) plus **chezmoi as the glue** between a Git-managed tree and `$HOME`.

## Path roles

| Kind | Aim | Typical env |
|------|-----|-------------|
| Config | App settings | `XDG_CONFIG_HOME` (~/.config) |
| Data | Persistent user data | `XDG_DATA_HOME` (~/.local/share) |
| Cache | Regenerable scratch | `XDG_CACHE_HOME` (~/.cache) |
| State | Logs, machine-local state | `XDG_STATE_HOME` (~/.local/state) |

Prefer env vars in shell init; where apps ignore XDG, bridge with template logic or documented symlinks—keep OS drift in chezmoi templates, not one-off edits in `$HOME`.

## Chezmoi flow

```bash
chezmoi diff && chezmoi status
chezmoi add ~/.path/to/file     # first registration
chezmoi re-add                  # push changes from destination back into source
chezmoi apply
chezmoi update                  # pull + apply (when remote is the source of truth)
cd "$(chezmoi source-path)" && git add … && git commit && git push
```

Work from `chezmoi source-path` for history; treat `$HOME` as the expanded view.

## Source naming (mental model)

| Pattern | Meaning |
|---------|---------|
| `dot_*` | Leading `.` in destination |
| `private_*` | Tight permissions |
| `executable_*` | Executable bit |
| `*.tmpl` | Go-template expansion |
| `run_once_*` / `run_after_*` | Scripted lifecycle around apply |

## Repo truth

Project docs under `docs/` (layout, design) override ad-hoc guesses. Do not store raw secrets in source; use chezmoi-age/secret patterns already defined in this repo.
