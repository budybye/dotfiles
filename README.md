# dotfiles

## 🍍🍕 0.8.0

### 🏴‍☠ [dotfiles](https://github.com/budybye/dotfiles)

- このリポジトリは、私の個人設定ファイルを管理するための dotfiles システムです。
- `chezmoi` で管理しています。
- さまざまなツールや設定ファイルを統合、管理、改善して、効率的に設定された環境を構築することを目的としています。
- `macOS` と `Ubuntu` の設定ファイルを管理しています。
- `Docker` や `Multipass` でも環境設定に対応しています。
- `Windows` や `WSL2` の設定ファイルも追加予定です。
- `FreeBSD` + `jail`への対応も追加予定
- `.github/workflows/*.yaml` で環境ごとのテスト、タグ設定、ghcr へ push を行っています。
- `~/.ssh/*` やシークレットな情報は `age` と `Bitwarden` で暗号化管理しています。
- `Dockerfile` と `docker-compose.yaml` と `devcontainer.json` で `Docker` コンテナを管理しています。
- `Github`, `VSCode`, `Cursor` の設定も管理しています。
- フォント、テーマ、壁紙、日本語設定も管理しています。
- `Brave`, `Cursor`, `Tabby`, `Xfce4` などデスクトップ環境も管理しています。
- プログラミング言語開発環境は `mise` で管理しています。

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

- [dotfiles](#dotfiles)
  - [🍍🍕 0.8.0](#-080)
    - [🏴‍☠ dotfiles](#-dotfiles)
    - [初期設定](#初期設定)
    - [git グローバル設定](#git-グローバル設定)
  - [概要](#概要)
  - [目次](#目次)
  - [ドキュメント](#ドキュメント)
  - [XDG Base Directory](#xdg-base-directory)
  - [管理方法](#管理方法)
  - [ツール一覧](#ツール一覧)
  - [Chezmoi の使用](#chezmoi-の使用)
    - [基本操作](#基本操作)
  - [Makefile](#makefile)
    - [よく使うコマンド](#よく使うコマンド)
  - [GitHub Actions](#github-actions)
  - [Mise](#mise)
    - [基本的な使い方](#基本的な使い方)
  - [環境変数](#環境変数)
  - [Docker](#docker)
  - [Multipass](#multipass)
  - [参考文献](#参考文献)

---

## ドキュメント

プロジェクトの詳細ドキュメントは`docs/`ディレクトリに配置されています：

- **[要件定義](docs/requirements.md)**: システムの要件定義
- **[設計書](docs/design.md)**: プロジェクト設計方針とアーキテクチャ（XDG Base Directory Specification 含む）
- **[タスク管理](docs/tasks.md)**: タスク管理と実行計画（AI 管理対応）
- **[技術スタック](docs/tech.md)**: 技術スタック、実装詳細（パッケージ管理含む）
- **[ディレクトリ構成](docs/directory.md)**: プロジェクトのディレクトリ構造

詳細な使用方法や設定については、各ドキュメントを参照してください。

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

このプロジェクトで管理しているツールとパッケージの詳細な一覧については、[技術スタック](docs/tech.md) を参照してください。

主なカテゴリ：

- **OS/プラットフォーム**: macOS、Ubuntu、Docker、Multipass、WSL2
- **開発ツール**: VSCode、Cursor、Neovim、Git、GitHub CLI
- **シェル・ターミナル**: Zsh、Fish、Bash、Starship、Sheldon
- **ランタイム管理**: Mise（Node.js、Python、Go、Rust、Ruby など）
- **パッケージ管理**: Homebrew、APT、Mise、Aqua、UV
- **セキュリティ**: Age、Bitwarden CLI、SSH
- **その他**: Docker、GitHub Actions、Dev Containers、その他多数

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

Mise は Rust 製のランタイムバージョン管理ツールです。プログラミング言語や CLI ツールのバージョンを管理します。`asdf` と互換性があり、`tool-versions` ファイルを使用できます。

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

**詳細**: [技術スタック - パッケージ管理 - Mise](docs/tech.md#miseランタイム管理) を参照してください。

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

- [Chezmoi](https://chezmoi.io/)
- [chezmoi/example](https://github.com/twpayne/dotfiles)
- [Makefile](https://www.gnu.org/software/make/manual/make.html)
- [Mise](https://mise.jdx.dev/)
- [Multipass](https://multipass.run/)
- [Docker](https://docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Git](https://git-scm.com/)
- [Github Actions](https://docs.github.com/en/actions)
- [Github Desktop](https://desktop.github.com/)
- [Github CLI](https://cli.github.com/)
- [ghcr](https://github.com/features/packages)
- [codespaces](https://docs.github.com/en/codespaces)
- [Dev Container](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/creating-a-dev-container-configuration)
- [Cursor](https://cursor.com)
- [VSCode](https://code.visualstudio.com/)
- [Zsh](https://zsh.org/)
- [Starship](https://starship.rs/)
- [Sheldon](https://sheldon.cli.rs/Introduction.html)
- [Fish](https://fishshell.com/)
- [Bitwarden](https://bitwarden.com)
- [Bun](https://bun.sh/)
- [Cargo](https://cargo.rust-lang.org/)
- [Go](https://go.dev/)
- [Vim](https://vim.org/)
- [IPFS](https://ipfs.io/)
- [Curl](https://curl.se/)
- [jq](https://github.com/jqlang/jq)
- [mkcert](https://github.com/FiloSottile/mkcert)
- [fzf](https://github.com/junegunn/fzf)
- [Homebrew](https://brew.sh/)
- [Xfce](https://xfce.org/)
- [xrdp](https://xrdp.org/)
- [Wireshark](https://wireshark.org/)
- [Editorconfig](https://editorconfig.org/)
- [Cloudflare Warp](https://developers.cloudflare.com/warp-client)
- [Wrangler](https://developers.cloudflare.com/wrangler)
- [Cloud-init-linter](https://github.com/anderssonPeter/cloud-init-linter)
- [Byobu](https://byobu.co/)
- [Tabby](https://tabby.sh/)
- [Neofetch](https://github.com/dylanaraps/neofetch)
- [ffmpeg](https://ffmpeg.org/)
- [MPD](https://www.musicpd.org/)
- [Ncmpcpp](https://github.com/ncmpcpp/ncmpcpp)
- [fcitx5](https://github.com/fcitx/fcitx5)
- [Fusuma](https://github.com/iberianpig/fusuma)
- [Karabiner-elements](https://karabiner-elements.pqrs.org/)
- [Aqua](https://aquaproj.github.io/)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [tldr](https://tldr.sh/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/)
- [Portainer](https://portainer.io/)
- [Monokai-Pro](https://github.com/monokai/monokai-pro)
- [WhiteSur-GTK-Theme](https://github.com/vinceliuice/WhiteSur-gtk-theme)
- [Xfce-look](https://xfce-look.org/)
- [PulseAudio Module for XRDP README](https://github.com/neutrinolabs/pulseaudio-module-xrdp/blob/master/README.md)
- [awesome](https://github.com/sindresorhus/awesome)
- [awesome-zsh-plugins](https://github.com/unixorn/awesome-zsh-plugins)
- [Rhino Linux](https://github.com/rhinolinux)
- [mac-defaults](https://github.com/kevinSuttle/macOS-Defaults)
- [Power Shell](https://docs.microsoft.com/en-us/powershell/)
- [Microsoft Remote Desktop](https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/clients/remote-desktop-mac)
- [WSL2](https://docs.microsoft.com/en-us/windows/wsl/wsl2-about)
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html)
- [Google Cloud CLI](https://cloud.google.com/sdk/docs/install-sdk)
- [DBeaver](https://dbeaver.io/)
- [Postman](https://www.postman.com/)
- [Insomnia](https://insomnia.rest/)
- [Caddy](https://caddyserver.com/)
- [Brave](https://brave.com/)
- [bookmarklet awesome](https://awesomebookmarklets.com/)
- [Tradingview](https://tradingview.com/)
- [Notion](https://notion.so/)
- [Obsidian](https://obsidian.md/)
- [Mp3tag](https://www.mp3tag.de/en/)
- [audacity](https://www.audacityteam.org/)
- [audacity-plugins-awesome](https://awesomeaudacityplugins.com/)
- [Blender](https://blender.org/)
- [Xcode](https://developer.apple.com/xcode/)
- [Android Studio](https://developer.android.com/studio)
- [Poetry](https://python-poetry.org/)
- [Jupyter Notebook](https://jupyter.org/)
- [Raspberry Pi](https://raspberrypi.org/)
- [HackGen Nerd Font](https://github.com/yuru7/HackGenNerdFont)
- [Reggae One Font](https://fonts.google.com/specimen/Reggae+One)
- [Roboto Mono Nerd Font JP](https://github.com/yuru7/RobotoMonoNerdFontJP)
- [Ansible](https://docs.ansible.com/)
- [Proxmox](https://www.proxmox.com/en/)
- [Vagrant](https://developer.hashicorp.com/vagrant/docs)
- [Flatpak](https://flatpak.org/)
- [Packer](https://developer.hashicorp.com/packer/docs)
