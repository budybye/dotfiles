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
- Symboliclink ~/dotfiles
- For `chezmoi diff`, use source-relative paths (example: `home/dot_pi/agent/agents/assistant.md`), not absolute real paths.

### Security

- Secret management: Bitwarden + age encryption.
- `.env` / `.env.*` files are read‑protected.
- Never expose API keys in code or logs.
- `make check` may prompt interactively (for example Bitwarden master password); treat prompt-wait as blocked verification, not a task failure.

---

## Context Management

When compacting context, always retain:

- A list of modified files.
- The test commands that were executed and their results.
- Any unresolved error messages.

After completing a task, run `/clear` to reset the context before moving on to the next task.

## Tool call

<tool_call_behavior>

- Before a meaningful tool call, send one concise sentence describing the immediate action.
- Always do this before edits and verification commands.
- Skip it for routine reads, obvious follow-up searches, and repetitive low-signal tool calls.
- When you preface a tool call, make that tool call in the same turn.

</tool_call_behavior>
