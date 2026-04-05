# AI ガイドライン

Chezmoi 管理の dotfiles（macOS / Ubuntu、XDG 準拠）。指示範囲内で処理し、不明点は確認を取る。

## ルール

- chezmoi, git, make で管理する。
- 明示されていない変更・見た目の変更は提案し、承認を得る。
- 依存は最小限。フォーマット・リントは別コミット。
- シェルスクリプト: `#!/usr/bin/env bash`、`set -eu`、ツール存在確認は `command -v`。
- 暗号化に `ssh` 管理や `age`, パスワード管理に `bitwarden`, env 管理に `mise` を使用する。
- zsh, rust系 cli, docker の環境を異なるOSでもなるべく統一する。

## 手順

1. **分析** — タスクを要約。[docs/tech.md](docs/tech.md) で技術スタック、[docs/directory.md](docs/directory.md) で配置ルールを確認。既存の類似実装の有無を確認。
2. **実行** — 配置ルールに従い実装。ステップごとに進捗を簡潔に報告。
3. **検証** — `chezmoi diff` または `make check` で確認。エラー時は原因を切り分け、修正後に再検証。

## 詳細ドキュメント

配置ルール・OS 分岐・環境差異などの詳細は [docs/](docs/) を参照。
