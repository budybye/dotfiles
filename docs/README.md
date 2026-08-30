---
name: docs-index
description: ドキュメント索引
---

# ドキュメント索引

See [bootstrap.md](bootstrap.md), [platform-matrix.md](platform-matrix.md), [context.md](context.md), [references.md](references.md), [security.md](security.md), [audit-checklist.md](audit-checklist.md), [git-to-jj.md](git-to-jj.md).

## 正本パス（ハイブリッド）

| 関心事 | 正本 |
|--------|------|
| OS パッケージ | `home/private_dot_config/mise.toml`（各 entry に `os` 制約） |
| CLI ツール | `mise/config.toml` `[tools]` |
| VS Code / skills | `packages.yaml` |
| 暗号化 | chezmoi `encrypted_*` |
| 開発タスク | `.mise.toml` `[tasks]` |

## Platform rules

- `brew:*`, `brew-cask:*`, `mas:*` → `os = "macos"`
- `apt:*` → `os = "linux"`
- `mise/ci.toml` → Mac full packages / Linux CLI packages
- `mise/docker.toml` → Linux CLI packages only
- `bootstrap.services` / `bootstrap.compose` → Ubuntu VM の systemd/Docker 用
- `bootstrap.macos.launchd` → macOS の LaunchAgent 用
- Docker container では system service bootstrap を実行しない
OpenSpec: `openspec/changes/chezmoi-to-mise-migration/`
