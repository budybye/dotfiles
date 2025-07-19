# Chezmoi Dotfiles Management System - AI Assistant Guidelines

## プロジェクト概要

このリポジトリは、**chezmoi**を使用した dotfiles 管理システムです。macOS と Ubuntu の設定ファイルを統合管理し、セキュリティとクロスプラットフォーム対応を重視しています。

## 主要技術スタック

### コア技術

- **Chezmoi**: ドットファイル管理システム
- **Age**: モダン暗号化ツール
- **Bitwarden/1Password CLI**: シークレット管理
- **XDG Base Directory**: 設定ファイル標準

### 対応環境

- **macOS**: Sequoia (14.0+)
- **Ubuntu**: 24.04 LTS
- **Docker**: コンテナ化環境
- **Multipass**: 軽量 VM 管理

## AI 支援開発の重点事項

### 1. セキュリティ優先

- 機密情報は必ず`age`暗号化またはパスワードマネージャー経由で管理
- SSH 鍵は暗号化して管理（`*.age`拡張子）
- シークレット情報はテンプレート変数で動的取得

### 2. クロスプラットフォーム対応

- OS 別設定は`.chezmoi.toml.tmpl`のテンプレート変数で制御
- 環境変数による動的分岐（`GITHUB_ACTIONS`, `CODESPACES`, `DOCKER`等）
- XDG Base Directory Specification 準拠

### 3. 設定ファイル管理

- 設定ファイルは`home/private_dot_config/`に配置
- シェルスクリプトは`home/.chezmoiscripts/`に配置
- テンプレートファイルは`*.tmpl`拡張子で管理

### 4. 開発ワークフロー

- **Makefile**: ビルド・管理スクリプト
- **GitHub Actions**: CI/CD 自動化
- **Dev Containers**: 開発環境のコンテナ化

## AI 支援時の注意事項

### 実装制約

- **暗号化ファイル**: `*.age`拡張子のファイルは変更禁止
- **テンプレート変数**: OS 別設定は既存のテンプレート変数を活用
- **XDG 準拠**: 設定ファイルは XDG Base Directory に配置
- **シークレット管理**: パスワードマネージャー経由でのみアクセス

### 開発ガイドライン

- 新しい設定追加時は適切なディレクトリに配置
- OS 別設定はテンプレート変数で分岐
- 暗号化が必要なファイルは`age`で暗号化
- パッケージ管理は`Brewfile`で一元管理

### 品質管理

- 設定変更前のバックアップ作成
- クロスプラットフォーム動作確認
- セキュリティ設定の検証
- テンプレート変数の整合性確認

## 参考資料

- [Chezmoi 公式ドキュメント](https://chezmoi.io/user-guide/)
- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/)
- [Age 暗号化ツール](https://age-encryption.org/)
- [Bitwarden CLI](https://bitwarden.com/help/cli/)

## 更新履歴

- **v0.7**: 現在のバージョン
- 335 回のリリースを重ねて継続改善
- macOS Sequoia と Ubuntu 24.04 に対応
- Docker/Multipass 環境での動作確認済み
