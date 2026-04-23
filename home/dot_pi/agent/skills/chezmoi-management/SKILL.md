---
name: chezmoi-management
description: hotmilk's personal chezmoi dotfiles operation manual. Summarizes source location, directory naming conventions, daily diff/apply flow, skill addition procedures, APM vs chezmoi boundaries, pre-commit (prek + secretlint), and troubleshooting. Refer when touching ~/.pi/, ~/.claude/, ~/.config/, ~/.zshrc, initializing new machines, or adding new skills.
---

# chezmoi Management (hotmilk personal)

Personal dotfiles management operation notes. Since chezmoi's official docs are sufficient, this document focuses only on **specifically how things work in my environment**.

## Prerequisites

| Item              | Value                                                                                             |
| ----------------- | ------------------------------------------------------------------------------------------------- |
| Source Directory  | `~/.local/share/chezmoi/`                                                                         |
| Remote            | `https://github.com/hotmilk/chezmoi-dotfiles.git`                                                 |
| Branch            | `main`                                                                                            |
| pre-commit        | [prek](https://github.com/j178/prek) + [secretlint](https://github.com/secretlint/secretlint)     |
| Post-apply hook   | `run_after_apm-install.sh` → `apm install --global --target claude`                               |

## Layout Quick Reference

```
~/.local/share/chezmoi/
├── dot_apm/          → ~/.apm/      (APM config)
├── dot_claude/       → ~/.claude/   (Claude Code)
│   ├── CLAUDE.md.tmpl
│   ├── settings.json.tmpl
│   ├── rules/
│   └── skills/       → ~/.claude/skills/   (Custom skills)
├── dot_codex/        → ~/.codex/
├── dot_config/       → ~/.config/   (helix, mise, sheldon, starship, zellij, zsh)
├── dot_pi/           → ~/.pi/       (pi config)
│   ├── agent/
│   │   └── skills/    → ~/.pi/agent/skills/ (Custom skills)
│   └── CLAUDE.md.tmpl
├── dot_zshrc         → ~/.zshrc
└── run_after_apm-install.sh  (scripts/run_after_* run after every apply)
```

## Filename Prefix Meanings

| prefix        | Meaning            | Example                                                   |
| ------------- | ------------------ | --------------------------------------------------------- |
| `dot_`        | Leading `.`        | `dot_zshrc` → `.zshrc`                                    |
| `executable_` | `+x` permission    | `executable_setup.sh` → `setup.sh` (755)                  |
| `private_`    | `0600` permission  | `private_key` → `key` (600)                               |
| `.tmpl`       | Go template        | `CLAUDE.md.tmpl` → `CLAUDE.md` expanded with hostname etc.|
| `run_once_`   | Run only once      | `run_once_install_brew.sh`                                |
| `run_after_`  | Run after apply    | `run_after_apm-install.sh`                                |

## References

For detailed information, see the reference documents:
- [Daily Commands](references/commands.md) - Commonly used commands and workflows
- [Skill Addition Process](references/skill-addition.md) - How to add and manage skills
- [Template Management](references/templates.md) - Working with .tmpl files
- [Pre-commit Hooks](references/pre-commit.md) - Managing prek + secretlint
- [Troubleshooting Guide](references/troubleshooting.md) - Common issues and solutions

## Quick Start

### Check what's different
```bash
chezmoi diff                   # Difference between source and dest
chezmoi status                 # General status
```

### Import changes from actual files to source
```bash
chezmoi add ~/.zshrc           # Add new file
chezmoi re-add                 # Bulk import changes to managed files
```

### Apply changes from source to actual files
```bash
chezmoi apply                  # Apply all changes
chezmoi apply --verbose        # Show what's happening
```

### Initialize on new machine
```bash
chezmoi init https://github.com/hotmilk/chezmoi-dotfiles.git --apply
cd $(chezmoi source-path)
prek install
```