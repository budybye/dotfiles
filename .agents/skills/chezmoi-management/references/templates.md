# Template Files Management

## Working with .tmpl Files

Files like `CLAUDE.md.tmpl` and `settings.json.tmpl` use Go templating:

```bash
chezmoi edit ~/.pi/CLAUDE.md     # Opens the source .tmpl file (not the destination)
chezmoi execute-template < foo.tmpl  # Manually test template expansion
chezmoi data                         # List available template variables (hostname, OS, etc.)
```

Template variables examples: `{{ .chezmoi.os }}`, `{{ .chezmoi.hostname }}`

**Critical Warning**: Running `chezmoi re-add` on `.tmpl` managed files will replace the template syntax in the source with the expanded destination content. To update `.tmpl` files, use `chezmoi edit` (which opens the source template) or directly edit `~/.local/share/chezmoi/dot_pi/CLAUDE.md.tmpl`.

**Pre-flight Check**: Always verify if a file is template-managed before using re-add:

```bash
chezmoi source-path ~/.pi/CLAUDE.md
# → /Users/hotmilk/.local/share/chezmoi/dot_pi/CLAUDE.md.tmpl
# If it ends with .tmpl, don't use re-add—edit manually instead
```

## Customizing Template Variables

Rather than hardcoding values in templates, define variables in the `[data]` section of `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
  claude_default_mode = "auto"
  github_username = "hotmilk"
```

Keep template structures like `{{ .claude_default_mode | default "acceptEdits" }}` intact and only modify values in `[data]` for maximum flexibility across different machines.