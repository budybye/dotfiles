# 要件定義 - Chezmoi Dotfiles Management System

## 概要

このドキュメントは、Chezmoi を使用した dotfiles 管理システムの要件定義を記載します。

## 機能要件

### 必須要件

- クロスプラットフォーム対応（macOS、Ubuntu）
- セキュリティ重視（暗号化、シークレット管理）
- XDG Base Directory Specification 準拠
- 自動化されたセットアッププロセス

### 推奨要件

- Docker/VM 環境での動作確認
- CI/CD 統合
- パッケージ管理の統一

## 非機能要件

### セキュリティ

- 機密情報の暗号化（age）
- パスワードマネージャー統合（Bitwarden/1Password）
- SSH 鍵の安全な管理

### メンテナンス性

- 明確なディレクトリ構造
- 包括的なドキュメント
- 一貫した命名規則

## 対応 OS・プラットフォーム要件

このシステムは以下の OS・プラットフォームに対応しています：

### 主要プラットフォーム

- **macOS**: Sequoia (14.0+) - プライマリ開発環境
- **Ubuntu**: 24.04 LTS (Noble Numbat) - Linux 開発環境
- **Docker**: ^24.0.0 - コンテナ化環境
- **Multipass**: ^1.13.0 - 軽量 VM 管理
- **WSL2**: Ubuntu 24.04 LTS - Windows Subsystem for Linux 2

### 将来対応予定

- **Windows**: ネイティブ Windows サポート（予定）
- **FreeBSD**: FreeBSD + jail 対応（予定）

## ツール要件

このシステムで管理・使用するツールの要件定義です。

### コアツール要件

| ツール         | macOS |  Ubuntu   |  Docker   | PowerShell | WSL2 |
| -------------- | :---: | :-------: | :-------: | :--------: | :--: |
| Chezmoi        | brew  | curl/mise | curl/mise |            |      |
| Make           | brew  |    apt    |    apt    |            |      |
| Zsh            | brew  |    apt    |    apt    |            |      |
| Git            | brew  |    apt    |    apt    |            |      |
| GitHub Actions |  ✅   |    ✅     |    ✅     |            |      |
| GitHub CLI     | brew  |    apt    |    apt    |            |      |
| Bitwarden CLI  | brew  | npm/snap  | npm/snap  |            |      |
| Docker         | brew  |    apt    |    apt    |            |      |
| Dev Container  |  ✅   |    ✅     |    ✅     |            |      |
| Multipass      | brew  |   snap    |   snap    |            |      |
| Homebrew       |  ✅   |    ❌     |    ❌     |            |      |

### CLI ツール要件

| ツール    | macOS | Ubuntu | Docker | PowerShell | WSL2 |
| --------- | :---: | :----: | :----: | :--------: | :--: |
| Byobu     | brew  |  apt   |  apt   |            |      |
| Vim       | brew  |  apt   |  apt   |            |      |
| Fish      | brew  |  apt   |  apt   |            |      |
| aqua VM   | brew  |  apt   |  apt   |            |      |
| MPD       | brew  |  apt   |  apt   |            |      |
| Ncmpcpp   | brew  |  apt   |  apt   |            |      |
| fcitx5    |  ❌   |  apt   |  apt   |            |      |
| Neofetch  |  ❌   |  apt   |  apt   |            |      |
| fastfetch | brew  |   ❌   |   ❌   |            |      |

### Rust ツール要件

| ツール         |   macOS    |   Ubuntu   |   Docker   | PowerShell | WSL2 |
| -------------- | :--------: | :--------: | :--------: | :--------: | :--: |
| Mise           |    brew    |    curl    |    curl    |            |      |
| cargo-binstall | mise/cargo | mise/cargo | mise/cargo |            |      |
| Starship       |    brew    | mise/cargo | mise/cargo |            |      |
| Sheldon        |    brew    |   cargo    |   cargo    |            |      |
| lsd            |    brew    | cargo/apt  |    apt     |            |      |
| bat            |    brew    | cargo/apt  |    apt     |            |      |
| ripgrep        |    brew    | cargo/apt  |    apt     |            |      |
| fzf            |    brew    | cargo/apt  |    apt     |            |      |
| zoxide         |    brew    | cargo/apt  |    apt     |            |      |
| fd-find        |    brew    | cargo/apt  |    apt     |            |      |

### ランタイム・言語要件

| ランタイム | macOS |  Ubuntu   |  Docker   | PowerShell | WSL2 |
| ---------- | :---: | :-------: | :-------: | :--------: | :--: |
| Node.js    | mise  |   mise    |   mise    |            |      |
| Bun        | mise  |   mise    |   mise    |            |      |
| Deno       | mise  | mise/snap | mise/snap |            |      |
| Go         | mise  | mise/snap | mise/snap |            |      |
| Python     | mise  | mise/apt  | mise/apt  |            |      |
| Java       | mise  | mise/apt  | mise/apt  |            |      |
| Rust       | mise  | mise/apt  | mise/apt  |            |      |
| Ruby       | mise  | mise/apt  | mise/apt  |            |      |
| PostgreSQL | mise  | mise/apt  | mise/apt  |            |      |
| Redis      | mise  | mise/apt  | mise/apt  |            |      |

### デスクトップアプリケーション要件

| アプリケーション   | macOS |  Ubuntu  |  Docker  | PowerShell | WSL2 |
| ------------------ | :---: | :------: | :------: | :--------: | :--: |
| Xfce4              |  ❌   |   apt    |   apt    |            |      |
| Xrdp               |  ❌   |   apt    |   apt    |            |      |
| VSCode             | brew  |    ❌    |   apt    |            |      |
| VSCodium           |  ❌   |   snap   |   snap   |            |      |
| Cursor             | brew  | AppImage | AppImage |            |      |
| GitHub Desktop     | brew  |   apt    |   apt    |            |      |
| Tabby              | brew  |   apt    |   apt    |            |      |
| Brave              | brew  |   apt    |   apt    |            |      |
| Cloudflare Warp    | brew  |   apt    |   apt    |            |      |
| Wireshark          | brew  |   apt    |   apt    |            |      |
| Fusuma             |  ❌   |   gem    |   gem    |            |      |
| Karabiner-Elements | brew  |    ❌    |    ❌    |            |      |

## ツールインストール要件

各プラットフォームでのツールインストール方法は、[技術スタック - パッケージ管理](./tech.md#パッケージ管理) を参照してください。

### パッケージ管理戦略

- **macOS**: Homebrew（formula、cask、mas）を使用
- **Ubuntu/Debian**: APT、Snap を使用
- **ランタイム管理**: Mise（Node.js、Python、Go など）を使用
- **Rust ツール**: Cargo、または Homebrew/APT を使用

## 関連ドキュメント

- [設計書](./design.md)
- [技術スタック](./tech.md)
- [タスク管理](./tasks.md)
- [ディレクトリ構成](./directory.md)
