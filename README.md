# dotfiles

## 🍍🍕 0.8.0

### 🏴‍☠ [dotfiles](https://github.com/budybye/dotfiles)

Chezmoi で管理する個人 dotfiles。macOS / Ubuntu の設定を統合し、XDG Base Directory に準拠しています。
[deepwiki](https://deepwiki.com/budybye/dotfiles)

- **管理**: `chezmoi` で設定ファイルを同期・テンプレート化
- **対応 OS**: `macOS` Sequoia、`Ubuntu` 24.04、`Docker`、`Multipass`
- **予定**: `WSL2`（[計画あり](docs/plans/2025-02-19-wsl2-support.md)）、`Windows`、`FreeBSD` + jail
- **CI/CD**: [`.github/workflows/`](.github/workflows/) でテスト、タグ、ghcr への push
- **セキュリティ**: `~/.ssh/*` やシークレットは `age` と `Bitwarden` で暗号化
- **コンテナ**: [`.devcontainer/`](.devcontainer/) で `arm` / `amd` クロスビルド、ghcr へ push
- **エディタ**: `VSCode`、`Cursor`、`Neovim` の設定を管理
- **デスクトップ**: `Brave`、`Tabby`、`Xfce4`、フォント・テーマ・壁紙
- **ランタイム**: `mise` で 60+ ツールを管理（[config.toml](home/private_dot_config/mise/config.toml)）

### 初期設定

- `curl` `git` `make` が必要です。

```sh
# chezmoi経由でリモートリポジトリから初期化
curl -fsLS https://chezmoi.io/get | sh -s -- -b ${HOME}/.local/bin init --apply budybye
# or
sh -c "$(curl -fsLS https://chezmoi.io/get)" -- -b ${HOME}/.local/bin init --apply budybye
```

ローカルに配置して初期化する場合：

```sh
cd ~
git clone git@github.com:budybye/dotfiles.git
cd dotfiles
make init
```

`chezmoi apply` で `run_*` スクリプトが実行されます。
独立したインストールスクリプトも実行できます：

```sh
# install.shを直接実行
./install.sh
```

**検証**: 変更後は `make check`（= `chezmoi diff`）で差分を確認。詳細は [計画書 - 検証方法](docs/plan.md#検証方法このプロジェクト) を参照。

### git グローバル設定

Git 設定は chezmoi テンプレート機能を使用して管理されます。`~/.config/git/user.conf`として配置され、テンプレート変数でユーザー情報を設定します。

**詳細**: [ディレクトリ構成 - Chezmoi 設計とワークフロー - ファイル管理](docs/directory.md#ファイル管理) を参照してください。

---

## 概要

- **Chezmoi**: `chezmoi` でドットファイルを管理しています。
- **対応 OS**: `macOS` Sequoia、`Ubuntu` 24.04 `chezmoi template` で OS ごとの設定を管理しています。
- **テスト**: `GitHub Actions` を使用して、さまざまな OS での動作を確認しています。
- **Makefile**: `Makefile` で設定管理しています。
- **今後の計画**: `arm64` 互換と `WSL2` と `Windows` 用の設定ファイルを追加で管理する予定です。
- **Docker**: `Dockerfile` と `docker-compose.yaml` と `devcontainer.json` で `Docker` コンテナを管理しています。
- **リリース**: [404 のリリース](https://github.com/budybye/dotfiles/releases)を重ね、継続的に改善されています。

## 目次

- [🍍🍕 0.8.0](#-080) — [初期設定](#初期設定) / [git グローバル設定](#git-グローバル設定)
- [概要](#概要)
- [ドキュメント](#ドキュメント) — [クイックリンク](#クイックリンク)
- [XDG Base Directory](#xdg-base-directory)
- [管理方法](#管理方法)
- [ツール一覧](#ツール一覧)
- [Chezmoi の使用](#chezmoi-の使用) — [基本操作](#基本操作)
- [Makefile](#makefile) — [よく使うコマンド](#よく使うコマンド)
- [GitHub Actions](#github-actions)
- [Mise](#mise) — [基本的な使い方](#基本的な使い方)
- [環境変数](#環境変数)
- [Docker](#docker)
- [Multipass](#multipass)
- [参考文献](#参考文献)

---

## ドキュメント

プロジェクトの詳細ドキュメントは`docs/`ディレクトリに配置されています：

| ドキュメント                          | 説明                                                                                      |
| ------------------------------------- | ----------------------------------------------------------------------------------------- |
| [計画書](docs/plan.md)                | 実装計画の索引・実行ガイド（[docs/plans/](docs/plans/) の詳細計画）                       |
| [セキュリティ](docs/security.md)      | 暗号化・シークレット管理・SSH・CI 環境の扱い                                              |
| [参考文献](docs/reference.md)         | ツール・ライブラリの公式ドキュメント・リポジトリ一覧                                      |
| [要件定義](docs/requirements.md)      | 対応 OS・ツール要件                                                                       |
| [環境差の注意点](docs/problems.md)    | プラットフォーム差・ライブラリの癖・トラブルシューティング                                |
| [設計書](docs/design.md)              | 設計方針・Makefile・[XDG Base Directory](docs/design.md#xdg-base-directory-specification) |
| [技術スタック](docs/tech.md)          | 技術一覧・[パッケージ管理](docs/tech.md#パッケージ管理)                                   |
| [ディレクトリ構成](docs/directory.md) | ファイル配置・[Chezmoi 設計](docs/directory.md#chezmoi-設計とワークフロー)                |
| [タスク管理](docs/tasks.md)           | タスクカテゴリ・優先度                                                                    |

**AI 向けガイドライン**: [AGENTS.md](AGENTS.md)（Cursor 向け）、[CLAUDE.md](CLAUDE.md)（Claude 向け）

### クイックリンク

- [Makefile コマンド一覧](docs/design.md#makefile-設計)
- [Chezmoi コマンドリファレンス](docs/directory.md#コマンドリファレンス)
- [検証方法（make check, chezmoi diff）](docs/plan.md#検証方法このプロジェクト)
- [新規設定追加時のチェックリスト](docs/problems.md#6-チェックリスト新規設定追加時)

---

## XDG Base Directory

このプロジェクトは[XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)に準拠しています。

設定ファイルは`~/.config`（`XDG_CONFIG_HOME`）に配置され、データファイルは`~/.local/share`（`XDG_DATA_HOME`）に配置されます。これにより、ホームディレクトリの整理と一貫したファイル管理を実現します。

**詳細**: [設計書 - XDG Base Directory Specification](docs/design.md#xdg-base-directory-specification) および [ディレクトリ構成](docs/directory.md) を参照してください。

**詳細なディレクトリ構成**: [ディレクトリ構成](docs/directory.md) を参照してください。

---

## 管理方法

このプロジェクトでは以下のアプローチで dotfiles を管理しています：

1. **Chezmoi**: ドットファイルの同期とテンプレート管理
2. **Makefile**: ビルドスクリプトとタスク自動化
3. **Dev Containers / VM**: コンテナや仮想マシン内での自動適用
4. **GitHub Actions**: クロスプラットフォームでの自動テスト

**詳細**: [設計書 - 開発ワークフロー](docs/design.md#開発ワークフロー) および [ディレクトリ構成 - Chezmoi 設計とワークフロー](docs/directory.md#chezmoi-設計とワークフロー) を参照してください。

**対応 OS・ツール要件**: [要件定義 - 対応 OS・プラットフォーム要件](docs/requirements.md#対応-osプラットフォーム要件) および [要件定義 - ツール要件](docs/requirements.md#ツール要件) を参照してください。

---

## ツール一覧

このセクションは**入口だけ**を保持し、詳細一覧は `docs/` に集約しています（README と docs の二重管理を避けるため）。

- 実データ（source of truth）
  - `home/private_dot_config/mise/config.toml`
  - `home/.chezmoidata/packages.yaml`
  - `home/private_dot_config/aquaproj-aqua/aqua.yaml`
- 詳細ドキュメント
  - [技術スタック](docs/tech.md)（パッケージマネージャー別一覧）
  - [要件定義](docs/requirements.md)（対応 OS / ツール要件）
  - [参考文献](docs/reference.md)（公式ドキュメント / リポジトリ URL）
  - [環境差の注意点](docs/problems.md)（OS 差分・運用時の注意）

### パッケージマネージャー（概要）

- [Mise](https://mise.jdx.dev/) - ランタイム/CLI のバージョン管理（主軸）
- [Homebrew](https://brew.sh/) - macOS の Formula/Cask
- [APT](https://wiki.debian.org/Apt) - Ubuntu の CLI/GUI パッケージ
- [Aqua](https://aquaproj.github.io/) - 宣言的 CLI 配布管理
- [Cargo](https://doc.rust-lang.org/cargo/) - Rust 製 CLI の導入
- Claude Skills - `packages.yaml` の `claude.skills` を通じた拡張管理

### Skills 参照先（代表）

- [Claude Code Docs](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/tutorials)
- [cloudflare/skills](https://github.com/cloudflare/skills)
- [sergiodxa/agent-skills](https://github.com/sergiodxa/agent-skills)
- [wshobson/agents](https://github.com/wshobson/agents)
- [antfu/skills](https://github.com/antfu/skills)
- [coderabbitai/skills](https://github.com/coderabbitai/skills)

> 注: 具体的なツール名・バージョン・有効/無効状態は `docs/tech.md` に集約。README では重複列挙しません。

---

## Chezmoi の使用

### 基本操作

```sh
# 初期化と適用
chezmoi init --apply budybye
# or
make init

# ソースディレクトリに移動
chezmoi cd

# ファイルを追加
chezmoi add <file>

# 変更を確認
chezmoi diff

# 変更を適用
chezmoi apply

# リモートから更新
chezmoi update
```

**詳細なコマンドリファレンスとワークフロー**: [ディレクトリ構成 - Chezmoi 設計とワークフロー](docs/directory.md#chezmoi-設計とワークフロー) を参照してください。

---

## Makefile

最適化された Makefile でよく使うコマンドを管理しています。`make help`で利用可能なコマンドを確認できます。

### よく使うコマンド

```sh
# ヘルプを表示
make help

# 初期化・更新
make init
make update
make apply

# Docker 操作
make docker-run
make docker-build

# 仮想マシン操作
make vm-create
make vm-start
make ssh

# セキュリティ
make age-keygen
make bw-unlock
```

**詳細なコマンドリファレンス**: [設計書 - Makefile 設計](docs/design.md#makefile-設計) を参照してください。

---

## GitHub Actions

Main Branch への Push 時に、様々な OS（macOS、Ubuntu、Docker、Windows）での自動テストを実行します。クロスプラットフォーム対応の Docker イメージをビルドして GitHub Packages にプッシュする機能も含まれています。

**詳細**: [技術スタック - 開発環境・CI/CD](docs/tech.md#開発環境cicd) を参照してください。

---

## Mise

Mise は Rust 製のランタイムバージョン管理ツールです。`asdf` 互換で `tool-versions` も扱えます。
運用方針・対象ツール一覧・他パッケージマネージャーとの役割分担は [技術スタック - パッケージ管理](docs/tech.md#パッケージ管理) に集約しています。

### 基本的な使い方

```sh
# ツールをインストール
mise use <tool@version>

# グローバルにインストール
mise use -g <tool@version>

# インストール済みツールを確認
mise ls

# ディレクトリを信頼（環境変数を読み込み）
mise trust
```

**詳細**: [技術スタック - Mise（ランタイム管理）](docs/tech.md#miseランタイム管理) を参照してください。

## 環境変数

環境変数は`.env`ファイルで管理し、Mise の`mise trust`コマンドで読み込みます。`~/.config/mise/config.toml`で自動読み込みファイルを指定できます。

**詳細**: [技術スタック - パッケージ管理](docs/tech.md#パッケージ管理) を参照してください。

---

## Docker

Dockerfile で Ubuntu 開発環境のイメージをビルドし、Dev Container として使用できます。`xrdp` と `xfce4` を使用した GUI 環境も構築可能です。`linux/amd64` と `linux/arm64` のマルチプラットフォーム対応です。

```sh
# Makefile経由で実行（推奨）
make docker-run

# 手動実行
cd .devcontainer
docker compose up -d
docker compose exec ubuntu /bin/bash
```

**詳細**: [設計書 - Makefile 設計 - Docker コマンド](docs/design.md#docker-コマンド) を参照してください。

---

## Multipass

Multipass を使用して cloud-init 経由で Ubuntu 仮想マシンを起動・管理できます。

```sh
# Makefile経由で実行（推奨）
make vm-create
make vm-start
make ssh

# 手動実行
multipass launch -n ubuntu -c 4 -m 8G -d 42G \
  --cloud-init cloud-init/multipass.yaml
```

**詳細**: [設計書 - Makefile 設計 - 仮想マシンコマンド](docs/design.md#仮想マシンコマンド-multipass) を参照してください。

---

## 参考文献

このプロジェクトで使用しているツールの公式ドキュメント・リポジトリ一覧は [参考文献（reference.md）](docs/reference.md) を参照。
