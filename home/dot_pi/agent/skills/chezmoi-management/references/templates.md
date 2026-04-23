# Template Files Management

## Working with .tmpl files

`CLAUDE.md.tmpl` や `settings.json.tmpl` は Go template:

```bash
chezmoi edit ~/.pi/CLAUDE.md     # 実体ではなく source の .tmpl が開く
chezmoi execute-template < foo.tmpl  # 手動で展開結果を確認
chezmoi data                         # 展開で使えるデータを一覧（ホスト名、OS 等）
```

Template variables example: `{{ .chezmoi.os }}`, `{{ .chezmoi.hostname }}`

**Important Note**: When running `chezmoi re-add` on `.tmpl` managed files (`CLAUDE.md.tmpl`, `settings.json.tmpl`, etc.), it will overwrite the source `.tmpl` syntax with the expanded dest content. To update `.tmpl` files, use `chezmoi edit` (which automatically opens the `.tmpl` side) or directly edit `~/.local/share/chezmoi/dot_pi/CLAUDE.md.tmpl`.

**Pre-check before re-add**: Always check if the target file is managed by `.tmpl` using `chezmoi source-path`:

```bash
chezmoi source-path ~/.pi/CLAUDE.md
# → /Users/hotmilk/.local/share/chezmoi/dot_pi/CLAUDE.md.tmpl
# If it ends with .tmpl, don't use re-add, manually edit instead. If not .tmpl, re-add is OK
```

## Changing Default Values for Template Variables

Instead of hardcoding values in the tmpl files themselves, place variables in the `[data]` section of `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
  claude_default_mode = "auto"
  github_username = "hotmilk"
```

Keep the tmpl structure like `{{ .claude_default_mode | default "acceptEdits" }}` and only change values in `[data]` for flexibility (leaving room to change settings between machines).