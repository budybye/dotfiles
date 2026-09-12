# Agent guidelines

Chezmoi-managed dotfiles (macOS / Ubuntu, XDG-aligned). Stay within the requested scope and ask when anything is unclear.

## Rules

- Manage with chezmoi, **jj** (primary VCS; git for remotes/CI via colocated repos), and make.
- Planning: `ROADMAP.md` is the project roadmap; OpenSpec is optional detail when a change needs structured artifacts.
- Propose changes that were not requested or that affect appearance only, then get approval.
- Keep dependencies minimal. Put formatting and lint changes in separate commits.
- Shell scripts: `#!/usr/bin/env bash`, `set -eu`, check tool availability with `command -v`.
- Use `ssh` / `age` for encryption, Bitwarden for passwords, mise for env management.
- Keep zsh, Rust CLI tooling, and Docker setups as aligned as practical across OSes.
- When adding a tool, update `docs/tech.md` and the relevant config files together for consistency.

## Workflow

1. **Analyze** — Summarize the task. Check stack in [docs/tech.md](docs/tech.md), layout rules in [docs/directory.md](docs/directory.md). Look for similar existing implementations.
2. **Implement** — Follow layout rules and implement. Report progress briefly per step.
3. **Verify** — Review with `git diff` or `jj diff`. On errors, isolate the cause, fix, and re-verify.

## Further docs

- Start with [README.md](README.md), which owns the document index and source-of-truth map.
- Use [ROADMAP.md](ROADMAP.md) for milestones and active work.
