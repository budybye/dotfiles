# Architecture (C4)

Chezmoi 管理の個人 dotfiles 向け C4 ドキュメント。Mermaid `C4*` 記法。

## 推奨閲覧順

| Level | ファイル | 対象 |
| --- | --- | --- |
| 1 Context | [c4-context.md](./c4-context.md) | 全員（境界の把握） |
| 2 Container | [c4-containers.md](./c4-containers.md) | 技術者 / PM |
| 3 Component | [c4-components-source.md](./c4-components-source.md) | 設定追加する開発者 |
| 4 Deployment | [c4-deployment.md](./c4-deployment.md) | 環境再現 / DevOps |
| Dynamic | [c4-dynamic-apply.md](./c4-dynamic-apply.md) | `chezmoi apply` フロー |
| Dynamic | [c4-dynamic-bootstrap.md](./c4-dynamic-bootstrap.md) | 初回セットアップ |
| Dynamic | [c4-dynamic-ci.md](./c4-dynamic-ci.md) | test → tag → GHCR / IPFS |

## 関連 docs

- [design.md](../design.md) — 設計方針・Makefile
- [directory.md](../directory.md) — 配置・chezmoi 規則
- [tech.md](../tech.md) — スタック・CI
- [security.md](../security.md) — age / Bitwarden / SSH
