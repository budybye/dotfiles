---
name: chezmoi-management
description: Personal chezmoi dotfiles management guide. Covers source structure, naming conventions, daily workflows, skill management, APM integration, pre-commit hooks, and troubleshooting. Reference when working with ~/.pi/, ~/.claude/, ~/.config/, ~/.zshrc, setting up new machines, or adding skills.
---

# Chezmoi Management (Personal Guide)

Personal dotfiles management notes. Since the official chezmoi documentation is comprehensive, this focuses specifically on **how things work in my environment**.

## Environment Setup

| Component         | Value                                                                                             |
| ----------------- | ------------------------------------------------------------------------------------------------- |
| Source Directory  | `~/.local/share/chezmoi/`                                                                         |
| Repository        | `https://github.com/hotmilk/chezmoi-dotfiles.git`                                                 |
| Branch            | `main`                                                                                            |
| Pre-commit        | [prek](https://github.com/j178/prek) + [secretlint](https://github.com/secretlint/secretlint)     |
| Post-apply Hook   | `run_after_apm-install.sh` → `apm install --global --target claude`                               |

## Directory Structure Overview

```
~/.local/share/chezmoi/
├── dot_apm/          → ~/.apm/      (APM configuration)
├── dot_claude/       → ~/.claude/   (Claude Code settings)
│   ├── CLAUDE.md.tmpl
│   ├── settings.json.tmpl
│   ├── rules/
│   └── skills/       → ~/.claude/skills/   (External skills)
├── dot_codex/        → ~/.codex/
├── dot_config/       → ~/.config/   (helix, mise, sheldon, starship, zellij, zsh)
├── dot_pi/           → ~/.pi/       (pi configuration)
│   ├── agent/
│   │   └── skills/    → ~/.pi/agent/skills/ (Custom skills)
│   └── CLAUDE.md.tmpl
├── dot_zshrc         → ~/.zshrc
└── run_after_apm-install.sh  (scripts/run_after_* execute after each apply)
```

## Filename Prefix Meanings

| Prefix        | Purpose            | Example                                                  |
| ------------- | ------------------ | -------------------------------------------------------- |
| `dot_`        | Leading `.`        | `dot_zshrc` → `.zshrc`                                   |
| `executable_` | Executable perms   | `executable_setup.sh` → `setup.sh` (755)                 |
| `private_`    | Restricted perms   | `private_key` → `key` (600)                              |
| `.tmpl`       | Go template        | `CLAUDE.md.tmpl` → Expanded `CLAUDE.md` with host info   |
| `run_once_`   | One-time execution | `run_once_install_brew.sh`                               |
| `run_after_`  | Post-apply scripts | `run_after_apm-install.sh`                               |

## References

Detailed documentation is available in these reference guides:
- [Daily Commands](references/commands.md) - Essential commands and workflows
- [Skill Management](references/skill-addition.md) - Adding and maintaining skills
- [Template Handling](references/templates.md) - Working with .tmpl files
- [Pre-commit Hooks](references/pre-commit.md) - Managing prek + secretlint
- [Troubleshooting](references/troubleshooting.md) - Solutions to common issues

## Quick Start

### Check Current Status
```bash
chezmoi diff                   # View differences between source and destination
chezmoi status                 # Overall status overview
```

### Sync Changes to Source
```bash
chezmoi add ~/.zshrc           # Add new files to source
chezmoi re-add                 # Update source with changes from managed files
```

### Apply Changes from Source
```bash
chezmoi apply                  # Apply all pending changes
chezmoi apply --verbose        # See detailed execution information
```

### New Machine Setup
```bash
chezmoi init https://github.com/hotmilk/chezmoi-dotfiles.git --apply
cd $(chezmoi source-path)
prek install
```