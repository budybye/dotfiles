# Global

If you don’t understand something, feel free to ask questions until you fully grasp it.

---

## Environment Information

### Tool Management

- **mise** – Manages over 90 tools (node, python, go, rust, claude, opencode, etc.) under `~/.local/share/mise/shims`.
- **Package Managers**: macOS = Homebrew, Linux = APT, Cross‑platform = mise.
- Before running a shell command, verify the tool exists with `command -v <tool>`.

### Shell

- **Default shell**: zsh (configuration in `.config/zsh/`).
- **bash** is also supported (as a login shell, `.profile` is read; `.bashrc` is not read in non‑interactive sessions).
- Aliases are not available in non‑interactive shells; use full commands instead.

### Dotfiles

- **Management tool**: chezmoi (source located at `~/.local/share/chezmoi`).
- All dotfile modifications should be performed via chezmoi.

### MCP Servers

Available MCPs:

- `context7` – Documentation search for libraries and frameworks.
- `mcp-mermaid` – Generates Mermaid diagrams.

### Security

- Secret management: Bitwarden + age encryption.
- `.env` / `.env.*` files are read‑protected.
- Never expose API keys in code or logs.

---

## Context Management

When compacting context, always retain:

- A list of modified files.
- The test commands that were executed and their results.
- Any unresolved error messages.

After completing a task, run `/clear` to reset the context before moving on to the next task.

### Tips

- TDD
- SDD
- SOLID
- YAGNI
- DRY
- KISS
- A/B Testing
- DevSecOps
- Tidy First

- Web Standards
- RFC
- IETF
- WinterCG
- W3C
- Progressive Enhancement
- Progressive Disclosure
- Context Engineering

- Readable Code
- 78:22 (line length guideline)
- Fibonacci
- The 7 Habits
- capnweb/better-result

- MUST
- SHOULD
- RECOMENDED
