---
name: requirements
description: 要件定義書
---
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
- パスワードマネージャー統合（Bitwarden desktop は macOS の任意パッケージ）
- SSH 鍵の安全な管理

### メンテナンス性

- 明確なディレクトリ構造
- 包括的なドキュメント
- 一貫した命名規則

## 対応 OS・プラットフォーム要件

このシステムは以下の OS・プラットフォームに対応しています：

### 主要プラットフォーム

- **macOS**: Sequoia (15.0+) - プライマリ開発環境
- **Ubuntu**: 26.04 LTS - Linux 開発環境（`make init` は Docker build と GitHub Actions で実行。LXD / RPi の job は cloud-init の起動確認までで `make init` は実行しない）
- **Docker**: ^24.0.0 - コンテナ化環境
- **Multipass**: ^1.13.0 - 軽量 VM 管理
- **WSL2**: 将来対応（未検証・ROADMAP M5）

### 将来対応予定

- **Kali Linux**: 対応進行中（ROADMAP M7）。Docker GUI image と LXD 経路のみ（`images:kali/current/cloud`）。multipass は Ubuntu 専用、OrbStack machine は Ubuntu / Debian 専用のため VM は LXD のみ。RDP は Ubuntu と同一の `xrdp + xorgxrdp + Xorg + XFCE` 経路
- **Omarchy**: 候補（未検証）。Arch + Hyprland（Wayland）構成のため xrdp は直接対応せず、リモートアクセスは wayvnc など別経路が前提。Docker / LXD より VM / 実機向き
- **Windows**: ネイティブ Windows サポート（予定）
- **FreeBSD**: FreeBSD + jail 対応（予定）

## ツール要件

このシステムで管理・使用するツールの要件定義です。
参照の温度感は [参考文献](./references.md) の `active / optional / legacy` タグを補助情報として使い、採用要件の正本は本書と [技術スタック](./tech.md)、および設定ファイル（`home/private_dot_config/mise/conf.d/tools.toml`、`home/private_dot_config/mise.toml`、`home/private_dot_config/Brewfile`、`home/.chezmoidata/packages.yaml`、`home/private_dot_config/aquaproj-aqua/aqua.yaml`）とします。

### コアツール要件

| ツール         | macOS |  Ubuntu   |  Docker   | PowerShell | WSL2 |
| -------------- | :---: | :-------: | :-------: | :--------: | :--: |
| Chezmoi        | curl/mise | curl/mise | curl/mise |            |      |
| Make           | brew  |    apt    |    apt    |            |      |
| Zsh            | brew  |    apt    |    apt    |            |      |
| Git            | brew  |    apt    |    apt    |            |      |
| GitHub Actions |  ✅   |    ✅     |    ✅     |            |      |
| GitHub CLI     | mise  |   mise    | apt/mise  |            |      |
| Bitwarden desktop | brew | — | — |            |      |
| Docker         | OrbStack | apt    |    apt    |            |      |
| Dev Container  |  ✅   |    ✅     |    ✅     |            |      |
| Multipass      |   —   |    —      |    —      |            |      |
| Homebrew       |  ✅   |    ❌     |    ❌     |            |      |
| Mise           | curl  |   curl    |   curl    |            |      |
| Age            | mise  |   mise    | apt/mise  |            |      |
| Aqua CLI       | mise  |   mise    |   mise    |            |      |

### CLI ツール要件

| ツール     | macOS | Ubuntu | Docker | PowerShell | WSL2 |
| ---------- | :---: | :----: | :----: | :--------: | :--: |
| Byobu      |   —   | cloud-init |  apt   |            |      |
| Vim        |   —   |  apt   |  apt   |            |      |
| Aqua       | mise  |  mise  |  mise  |            |      |
| MPD        | brew  |  apt   |  apt   |            |      |
| Ncmpcpp    | brew  |  apt   |  apt   |            |      |
| fcitx5     |  ❌   |  apt   |  apt   |            |      |
| fastfetch  | mise  |  mise  |  mise  |            |      |
| shellcheck | mise  |  mise  |  mise  |            |      |

### Rust ツール要件

| ツール         |   macOS    |   Ubuntu   |   Docker   | PowerShell | WSL2 |
| -------------- | :--------: | :--------: | :--------: | :--------: | :--: |
| Mise           |    curl    |    curl    |    curl    |            |      |
| cargo-binstall | mise/cargo | mise/cargo | mise/cargo |            |      |
| Starship       |    mise    |    mise    |    mise    |            |      |
| Sheldon        |    mise    |    mise    |    mise    |            |      |
| lsd            |    mise    |    mise    |    mise    |            |      |
| bat            |    mise    |    mise    |    mise    |            |      |
| ripgrep        |    mise    |    mise    |    mise    |            |      |
| fzf            |    mise    |    mise    |    mise    |            |      |
| zoxide         |    mise    |    mise    |    mise    |            |      |
| fd-find        |    mise    |    mise    |    mise    |            |      |

### ランタイム・言語要件

| ランタイム | macOS |  Ubuntu   |  Docker   | PowerShell | WSL2 |
| ---------- | :---: | :-------: | :-------: | :--------: | :--: |
| Node.js    | mise  |   mise    |   mise    |            |      |
| Bun        | mise  |   mise    |   mise    |            |      |
| Deno       |   —   |     —     |     —     |            |      |
| Go         | mise  |   mise    |   mise    |            |      |
| Python     | mise  |   mise    |   mise    |            |      |
| Java       | mise  |   mise    |   mise    |            |      |
| Rust       | mise  |   mise    |   mise    |            |      |
| Ruby       | mise  | mise/apt  | mise/apt  |            |      |
| Redis      |   —   |     —     |     —     |            |      |

### デスクトップアプリケーション要件

| アプリケーション   | macOS |  Ubuntu  |  Docker  | PowerShell | WSL2 |
| ------------------ | :---: | :------: | :------: | :--------: | :--: |
| Xfce4              |  ❌   |   apt    |   apt    |            |      |
| Xrdp               |  ❌   |   apt    |   apt    |            |      |
| VSCode             |  —    |    ❌    |    —     |            |      |
| VSCodium           |  ❌   |    —     |    —     |            |      |
| Cursor             |  —    |    —     |    —     |            |      |
| GitHub Desktop     | brew  |   deb    |   deb    |            |      |
| Tabby              |  —    |    —     |    —     |            |      |
| Brave              | brew  |   apt    |   apt    |            |      |
| Cloudflare Warp    | brew  |    —     |    —     |            |      |
| Wireshark          | brew  |   apt    |   apt    |            |      |
| Fusuma             |  ❌   |   gem    |   gem    |            |      |
| Karabiner-Elements |  —    |    ❌    |    ❌    |            |      |

## ツールインストール要件

各プラットフォームでのツールインストール方法は、[技術スタック - パッケージ管理](./tech.md#パッケージ管理) を参照してください。

### パッケージ管理戦略

- **macOS**: Homebrew（formula、cask）を使用。bootstrap は `mise.toml` の `brew:` / `brew-cask:` を `mise bootstrap packages apply` で入れる。mas は適用しない。`Brewfile` は `bb` / `bcf` だけが読む別の一覧で、一本化は未了（ROADMAP M2）
- **Ubuntu/Debian**: APT を使用（Snap は未使用）
- **ランタイム管理**: Mise（Node.js、Python、Go など）を使用
- **Rust ツール**: Cargo または Mise を優先し、必要時に Homebrew/APT を使用
- **宣言的CLI管理**: Aqua CLI でクロスプラットフォーム配布を管理
- **バージョン固定**: ほぼ全て `latest`。`lockfile = true` だがロックは `mise lock --global` を実行したマシンだけにできる（リポジトリ管理外。詳細は [技術スタック](./tech.md)）

## 関連ドキュメント

- [アーキテクチャ](./architecture.md)
- [技術スタック](./tech.md)
- [ロードマップ](../ROADMAP.md)
- [ディレクトリ構成](./directory.md)

## プロファイル要件

- workstation は full package / GUI profile として扱う。
- CI は Linux CLI package を基本とする。ただし CI では `linux/gui.sh` と `linux/setup.sh`、Docker Full image では `linux/gui.sh` が実行される。これは意図的（Full image はデスクトップ image で、CI は `make init` 全体を検証する。`gui.sh` の追加 package は xrdp を壊す `light-locker` / `xscreensaver` を要求しない）。profile 分離は ROADMAP M2 の別課題。
- Docker は secret、SDDM、systemd を持ち込まない。Full image は xfce4 / xorgxrdp / xrdp を含み、Slim image の Dockerfile は xrdp を入れない。
- profile の package 定義は Mise（apt / brew / brew-cask）。`Brewfile`（macOS の `bb` / `bcf` 用）は別の一覧。Chezmoi data は extensions / skills / platform-specific data に限定する。
