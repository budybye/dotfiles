---
name: tech
description: 技術スタック パッケージ管理 ライブラリ説明
---
# 技術スタック - Chezmoi Dotfiles Management System

## ドキュメント方針

- このファイルは「実際に使っている技術と管理元」を記載する
- 詳細な手順は `README.md`、参照リンク集は `docs/reference.md` に集約する
- `docs/reference.md` のタグ（`active` / `optional` / `legacy`）は参照の温度感を示す補助情報で、採用判断の正本は本ファイルと設定ファイルに置く
- source of truth は次の3つ
  - `home/private_dot_config/mise/config.toml`
  - `home/.chezmoidata/packages.yaml`
  - `home/private_dot_config/aquaproj-aqua/aqua.yaml`

## コア技術

- **Chezmoi**: dotfiles 管理の中核
- **Mise**: 言語ランタイムと CLI の統合管理
- **Homebrew / APT / Snap / Winget / Scoop**: OS ごとのパッケージ管理
- **Aqua**: 宣言的な追加 CLI 管理
- **Cargo / npm / Go / Python**: 言語別 CLI 配布

## 対応 OS・プラットフォーム

- **macOS Sequoia**
- **Ubuntu 24.04 LTS**
- **Docker / Dev Container**
- **Multipass**
- **Windows (Winget / Scoop 経由で一部管理)**

## パッケージ管理

### Mise（主軸）

- 設定: `home/private_dot_config/mise/config.toml`
- 役割:
  - Node.js, Python, Go, Rust, Java などのランタイム管理
  - `gh`, `wrangler`, `lazygit`, `jq`, `yq` など CLI 管理
- 運用:
  - 多くのツールを `latest` で管理
  - `legacy_version_file = true` と `asdf_compat = true` を有効化
  - `env_file = ".env"` で環境変数連携

### packages.yaml（クロスプラットフォーム）

- 設定: `home/.chezmoidata/packages.yaml`
- 役割:
  - `darwin.formula`, `darwin.cask`
  - `linux.cli`, `linux.gui`, `snap`
  - `windows.winget`, `windows.scoop`
  - `cargo`, `npm`, `go`, `python`
  - `claude.skills`

### Aqua（補助）

- 設定: `home/private_dot_config/aquaproj-aqua/aqua.yaml`
- 現在の定義:
  - `b3nj5m1n/xdg-ninja@v0.2.0.2`

## 実際に利用している主要カテゴリ

### シェル・ターミナル

- **zsh**（デフォルト）
- **bash**（互換用）
- **starship**
- **sheldon**

### 開発・CI/CD

- **git / gh**
- **docker / devcontainer-cli**
- **github actions（workflow）**
- **pre-commit**

### クラウド・インフラ

- **wrangler**
- **cloudflared**
- **gcloud**

### セキュリティ

- **age**
- **bitwarden**
- **ssh**

## 注意事項

- 具体的な「どのツールが有効か」はコメントアウト状態も含め `mise/config.toml` と `packages.yaml` を優先する
- README は概要のみを保持し、ツール一覧の重複列挙はしない
- バージョンの厳密な固定値が必要な場合は、個別ファイル（`mise`, `aqua`, lockfile）を更新する

## 関連ドキュメント

- [README](../README.md)
- [要件定義](./requirements.md)
- [設計書](./design.md)
- [ディレクトリ構成](./directory.md)
- [環境差の注意点](./problems.md)
- [参考文献](./reference.md)
