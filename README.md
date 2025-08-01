<!-- <link href="./style.css" rel="stylesheet"></link> -->

# dotfiles

## 🍍🍕 0.7.*

### 🏴‍☠ [budybye/dotfiles](https://github.com/budybye/dotfiles)

- このリポジトリは、私の個人設定ファイルを管理するための dotfiles システムです。
- `chezmoi` で管理しています。
- さまざまなツールや設定ファイルを統合、管理、改善して、効率的に設定された環境を構築することを目的としています。
- `macOS` と `Ubuntu` の設定ファイルを管理しています。
- `Docker` や `Multipass` でも環境設定に対応しています。
- `Windows` や `WSL2` の設定ファイルも追加予定です。
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

```sh
# ~/.config/git/user.conf を分けて設定している
cat <<EOF >~/.config/git/user.conf
[user]
    name = {{ .name }}
    email = {{ .email }}
EOF

# or
git config --global user.name {{ .name }}
git config --global user.email {{ .email }}
# コミットメッセージのテンプレート
git config --global commit.template ~/.config/git/commit_template
# ~/.config/git/config の設定の確認
git config --list
```

---

## 概要

- **Chezmoi**: `chezmoi` でドットファイルを管理しています。
- **対応 OS**: `macOS` Sequoia、`Ubuntu` 24.04 `chezmoi template` で OS ごとの設定を管理しています。
- **テスト**: `GitHub Actions` を使用して、さまざまな OS での動作を確認しています。
- **Makefile**: `Makefile` で設定管理しています。
- **今後の計画**: `arm64` 互換と `WSL2` と `Windows` 用の設定ファイルを追加で管理する予定です。
- **Docker**: `Dockerfile` と `docker-compose.yaml` と `devcontainer.json` で `Docker` コンテナを管理しています。
- **リリース**: [335 のリリース](https://github.com/budybye/dotfiles/releases)を重ね、継続的に改善されています。

## 目次

1. [XDG ディレクトリ構成](#XDG-Base-Directory)
2. [管理方法](#管理方法)
3. [Chezmoi](#Chezmoi)
4. [Makefile](#Makefile)
5. [Github Actions](#Github-Actions)
6. [Mise](#Mise)
7. [環境変数](#環境変数)
8. [Docker](#Docker)
9. [Multipass](#Multipass)
10. [参考文献](#参考文献)

---

## XDG Base Directory

### [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)

- XDG Base Directory Specification に基づくディレクトリの設定を行います。
- **XDG_CONFIG_HOME**: ユーザー固有の設定ファイルの格納先。
- **XDG_DATA_HOME**: ユーザー固有のデータファイルの格納先。
- **XDG_CACHE_HOME**: ユーザー固有のキャッシュファイルの格納先。
- **XDG_STATE_HOME**: ユーザー固有の状態ファイルの格納先。
- **XDG_DATA_DIRS**: システム全体のデータファイルの検索パス。
- **XDG_CONFIG_DIRS**: システム全体の設定ファイルの検索パス。
- 環境変数で設定できますが、なるべくデフォルトを使用します。
- 特に `~/.config` は様々なツールに使用されているので、なるべく採用します。

```:tree
.
├── .devcontainer/
│   ├── docker-compose.yaml
│   ├── Dockerfile
│   ├── devcontainer.json
│   └── entrypoint.sh
├── .github/
│   └── workflows/
│       ├── test.yaml
│       ├── push.yaml
│       └── tag.yaml
├── .vscode/
│   └── extensions.json
├── .cursor/
│   └── rules/
│       ├── always-refer.mdc
│       ├── project-structure.mdc
│       ├── package-management.mdc
│       └── development-guidelines.mdc
├── cloud-init/
│   ├── multipass.yaml
│   ├── network-config
│   └── user-data
├── home/
│   ├── .chezmoidata/
│   │   └── packages.yaml
│   ├── .chezmoiscripts/
│   │   ├── darwin/
│   │   ├── linux/
│   │   └── run_*.sh.tmpl
│   ├── dot_ssh/
│   │   ├── config.tmpl
│   │   ├── encrypted_private_*.age
│   │   └── *.pub.tmpl
│   ├── private_dot_config/
│   │   ├── alacritty/
│   │   ├── git/
│   │   ├── nvim/
│   │   ├── tmux/
│   │   ├── fish/
│   │   ├── mise/
│   │   ├── Brewfile
│   │   └── starship.toml
│   ├── .chezmoi.toml.tmpl
│   ├── .chezmoiexternal.toml.tmpl
│   ├── .chezmoiignore
│   ├── dot_zshrc
│   ├── dot_bashrc
│   ├── dot_profile
│   ├── key.txt.age
│   └── shhh.txt
├── .chezmoiroot
├── .editorconfig
├── .tool-versions
├── install.sh
├── Makefile
├── README.md
├── style.css
└── .gitignore
```

- **シェル設定**: ログインシェルやインタラクティブシェルで読み込まれるファイル。
- **Makefile**: `Makefile` で シェルスクリプトを設定管理。
- **.chezmoiscripts**: 初期設定用などのシェルスクリプトを格納するディレクトリ。
- **.devcontainer**: `docker` と `devcontainer` 使用する設定ファイル。
- **.github**: `Github Actions` の設定ファイル。OS 差異のテスト用やイメージビルド用。
- **.cursor**: `Cursor AI` の設定ファイルと開発ガイドライン。
- **~/.config**: 様々なツールやアプリケーションの設定を管理するためのファイル。
- **.local/share**: ユーザーがインストールしたフォントや壁紙などの共有リソースを格納するディレクトリ。

---

## 管理方法

### 1. Chezmoi の活用

- [x] **クロスプラットフォーム対応**: macOS、Linux、Windows 間でドットファイルを同期
- [x] **セキュリティ**: シークレットファイルを暗号化して管理
- [x] **テンプレート機能**: 環境ごとの設定を柔軟にカスタマイズ

### 2. Make との併用

- [x] **特定の設定やスクリプトの自動化**: Makefile を使用
- [x] **Chezmoi との連携**: ドットファイルの管理は Chezmoi に任せる

### 3. .devcontainer との統合

- [x] **Dev Containers 内で Chezmoi を使用**: コンテナ起動時に自動的にドットファイルを適用

### 4. Github Actions でテスト

```mermaid
flowchart TD
    A[ドットファイル管理] --> B[Chezmoi]
    A --> C[Make]
    A --> D[Docker]
    A --> E[Multipass]

    B --> B1[初期化]
    B1 --> B2[設定ファイルを適用]
    B2 --> B3[環境変数を管理]

    C --> C1[Makefileを使用]
    C1 --> C2[シェルスクリプトを実行]
    C2 --> C3[環境ごとの設定を管理]

    D --> D1[Dockerイメージをビルド]
    D1 --> D2[コンテナを起動]
    D2 --> D3[環境を構築]

    E --> E1[MultipassでVMを起動]
    E1 --> E2[cloud-initを使用]
    E2 --> E3[カスタマイズされた環境を構築]
```

```mermaid
sequenceDiagram
    participant H as Home Directory
    participant W as Working Copy
    participant L as Local Repo
    participant R as Remote Repo

    H->>L: chezmoi init
    H->>W: chezmoi add <file>
    W->>W: chezmoi edit <file>
    W-->>H: chezmoi diff
    W->>H: chezmoi apply
    H-->>W: chezmoi cd
    W->>L: git add .
    W->>L: git commit
    L->>R: git push
    R->>H: chezmoi init --apply <repo>
```

### Script

| Chezmoi Script                       | MacOS | Ubuntu | wsl | powershell |
| ------------------------------------ | :---: | :----: | :-: | :--------: |
| run_once_before_age.sh.tmpl          |  ✅   |   ✅   |     |            |
| run_once_before_bw.sh.tmpl           |  ✅   |   ✅   |     |            |
| run_after_activate.sh.tmpl           |  ✅   |   ✅   |     |            |
| run_onchange_after_bootstrap.sh.tmpl |  ✅   |        |     |            |
| run_onchange_after_defaults.sh.tmpl  |  ✅   |        |     |            |
| run_onchange_after_cli.sh.tmpl       |       |   ✅   |     |            |
| run_once_after_docker.sh.tmpl        |       |   ✅   |     |            |
| run_onchange_after_gui.sh.tmpl       |       |   ✅   |     |            |
| run_once_after_setup.sh.tmpl         |       |   ✅   |     |            |
| run_onchange_after_snap.sh.tmpl      |       |   ✅   |     |            |
| run_once_after_ssh.sh.tmpl           |  ✅   |   ✅   |     |            |
| run_onchange_after_vscode.sh.tmpl    |  ✅   |   ✅   |     |            |
| run_onchange_after_with.sh.tmpl      |  ✅   |   ✅   |     |            |
| run_onchange_after_xrp.sh.tmpl       |  ✅   |   ✅   |     |            |
| run_once_after_youtube.sh.tmpl       |  ✅   |   ✅   |     |            |

### Script rule

- `.chezmoiscripts` ディレクトリ内に配置することで `chezmoi apply` 時に実行される
- `.tmpl` は `chezmoi apply` でテンプレートとして認識されます。
- `run_` は `chezmoi apply` で名前順に実行されます。
- `once_` は `chezmoi apply` 一度だけ実行されます。
- `onchange_` は 前回の `chezmoi apply` から変更があった場合に実行されます。
- `before_` は `chezmoi apply` 前に実行されます。
- `after_` は `chezmoi apply` 後に実行されます。
- それぞれの script は `after_` `before_` `onchange_` `once_` `run_` `.tmpl` などの chezmoi 構文を除いた名前になります。

### chezmoiignore

- `chezmoiignore` で `chezmoi apply` で除外するファイルを管理できます。
- 除外されたファイルは `chezmoi ignored` で確認できます。

```txt:.chezmoiignore
# template構文を使用できます

{{ if ne .chezmoi.os "linux" }}
.config/fcitx5
.config/fusuma
.local/share/fonts
.local/share/icons
.local/share/themes
.chezmoiscripts/linux/**
{{ end }}

.chezmoiexternal.*
key.txt.age
shhh.txt
```

### ツールのインストール

---

| _OS_           | MacOS |  Ubuntu   |  Docker   | PowerShell | WSL2 |
| -------------- | :---: | :-------: | :-------: | :--------: | :--: |
| Chezmoi        | brew  | curl/mise | curl/mise |            |      |
| Make           | brew  |    apt    |    apt    |            |      |
| ZSH            | brew  |    apt    |    apt    |            |      |
| Git            | brew  |    apt    |    apt    |            |      |
| Github Actions |  ✅   |    ✅     |    ✅     |            |      |
| Github CLI     | brew  |    apt    |    apt    |            |      |
| Bitwarden CLI  | brew  | npm/snap  | npm/snap  |            |      |
| Docker         | brew  |    apt    |    apt    |            |      |
| Dev Container  |  ✅   |    ✅     |    ✅     |            |      |
| Multipass      | brew  |   snap    |   snap    |            |      |
| Homebrew       |  ✅   |    ❌     |    ❌     |            |      |

---

| _CLI Tool_ | MacOS | Ubuntu | Docker | PowerShell | WSL2 |
| ---------- | :---: | :----: | :----: | :--------: | :--: |
| Byobu      | brew  |  apt   |  apt   |            |      |
| Vim        | brew  |  apt   |  apt   |            |      |
| Fish       | brew  |  apt   |  apt   |            |      |
| aqua VM    | brew  |  apt   |  apt   |            |      |
| MPD        | brew  |  apt   |  apt   |            |      |
| Ncmpcpp    | brew  |  apt   |  apt   |            |      |
| fcitx5     |  ❌   |  apt   |  apt   |            |      |
| Neofetch   |  ❌   |  apt   |  apt   |            |      |
| fastfetch  | brew  |   ❌   |   ❌   |            |      |

---

| _Rust Tool_    |   MacOS    |   Ubuntu   |   Docker   | PowerShell | WSL2 |
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

---

| _Lang/Runtime_ | MacOS |  Ubuntu   |  Docker   | PowerShell | WSL2 |
| -------------- | :---: | :-------: | :-------: | :--------: | :--: |
| Node.js        | mise  |   mise    |   mise    |            |      |
| Bun            | mise  |   mise    |   mise    |            |      |
| Deno           | mise  | mise/snap | mise/snap |            |      |
| Go             | mise  | mise/snap | mise/snap |            |      |
| Python         | mise  | mise/apt  | mise/apt  |            |      |
| Java           | mise  | mise/apt  | mise/apt  |            |      |
| Rust           | mise  | mise/apt  | mise/apt  |            |      |
| Ruby           | mise  | mise/apt  | mise/apt  |            |      |
| PostgreSQL     | mise  | mise/apt  | mise/apt  |            |      |
| Redis          | mise  | mise/apt  | mise/apt  |            |      |

---

| _Desktop_          | MacOS |  Ubuntu  |  Docker  | PowerShell | WSL2 |
| ------------------ | :---: | :------: | :------: | :--------: | :--: |
| Xfce4              |  ❌   |   apt    |   apt    |            |      |
| Xrdp               |  ❌   |   apt    |   apt    |            |      |
| VSCode             | brew  |    ❌    |   apt    |            |      |
| VSCodium           |  ❌   |   snap   |   snap   |            |      |
| Cursor             | brew  | AppImage | AppImage |            |      |
| Github Desktop     | brew  |   apt    |   apt    |            |      |
| Tabby              | brew  |   apt    |   apt    |            |      |
| Brave              | brew  |   apt    |   apt    |            |      |
| Cloudflare Warp    | brew  |   apt    |   apt    |            |      |
| Wireshark          | brew  |   apt    |   apt    |            |      |
| Fusuma             |  ❌   |   gem    |   gem    |            |      |
| Karabiner-Elements | brew  |    ❌    |    ❌    |            |      |

---

## [Chezmoi](https://chezmoi.io/) の使用

### Chezmoi を使用して Dotfiles を管理します

- `chezmoi init` で初期化して `chezmoi cd` で移動して `chezmoi add` でファイルを追加します。
- `chezmoi apply` で変更を適用します。
- `chezmoi diff` で差分を確認します。
- `chezmoi chattr` でファイルの属性を変更します。
- `chezmoi update` でリモートからの状態を反映します。
- `chezmoi data` で .chezmoi.\* から取得できる情報を表示します。

```sh
# インストールされてない場合
curl -sfL https://chezmoi.io/get | sh -s -- init --apply budybye
# or
make init

# MacOS
brew install chezmoi

# 初期化 ~/.local/share/chezmoi が作成されて ~/ 以下に反映される
chezmoi init --apply budybye
# cd コマンドで移動 ~/.local/share/chezmoi
chezmoi cd
# ファイルを追加
chezmoi add < Filename >
# ファイルを追加(シンボリックリンク)
chezmoi add --follow < Filename >
# ファイルの差分を確認
chezmoi diff < option Filename >
# 変更を適用
chezmoi apply < option Filename >
# ファイルの属性を変更
chezmoi chattr < Filename >
# リモートからの状態を反映
chezmoi update
# .chezmoi.* から取得できる情報を表示
chezmoi data
```

---

## [Makefile](https://www.gnu.org/software/make/manual/make.html)

### 最適化された Makefile でよく使うコマンドを管理

最新の Makefile は構造化され、カテゴリ別に整理されています。`make help`で利用可能なコマンドを確認できます。

#### 基本コマンド

```sh
# ヘルプメッセージを表示
make help
# バージョン情報を表示
make version
# dotfiles を初期化
make init
# dotfiles を更新
make update
# 変更を適用
make apply
# 設定をチェック
make check
```

#### Docker 関連

```sh
# Docker イメージをビルド
make docker-build
# Docker コンテナをビルドして実行
make docker-run
# Docker Compose でサービスを開始
make up
# Docker Compose でサービスを停止
make down
# Docker コンテナに接続
make exec
# Docker コンテナのログを表示
make logs
```

#### 仮想マシン (Multipass) 関連

```sh
# Multipass VM を作成
make vm-create
# VM 情報を表示
make vm-info
# VM を停止
make vm-stop
# VM を開始
make vm-start
# SSH で VM に接続
make ssh
```

#### Git 操作

```sh
# 変更をコミットしてプッシュ
make git-commit
# Git ステータスを表示
make git-status
```

#### セキュリティ・暗号化

```sh
# Age 暗号化キーを生成
make age-keygen
# Bitwarden Vault をアンロック
make bw-unlock
```

#### クリーンアップ

```sh
# Docker リソースをクリーンアップ
make clean-docker
# VM を削除
make clean-vm
# 全ての一時ファイルをクリーンアップ
make clean
```

#### 情報表示

```sh
# VM の一覧を表示
make list-vms
# Docker コンテナの一覧を表示
make list-containers
# システム情報を表示
make system-info
```

#### レガシーエイリアス

```sh
# docker-run のエイリアス
make docker
# vm-create のエイリアス
make ubuntu
# git-commit のエイリアス
make git
# age-keygen のエイリアス
make age
# bw-unlock のエイリアス
make bw
```

### Makefile の特徴

- **カテゴリ化**: コマンドが論理的にグループ分けされています
- **カラー出力**: 視認性の良い緑色の成功メッセージ
- **エラーハンドリング**: 安全なコマンド実行
- **設定可能な変数**: 簡単にカスタマイズ可能
- **依存関係管理**: ターゲット間の依存関係が明確
- **ヘルプ機能**: `make help` で全コマンドの説明を表示

---

## [Github Actions](https://docs.github.com/en/actions)

- `Main Branch` に Push されたときにテストします。
- `Github Actions` を使用すると様々な OS でテストできます。
- `Docker` 製の action を使用して Image を Build して `Github Packages` に Push できます。
- `Cross Platform` 対応の Image を作成して `Github Packages` に Push したい。
- `Runs_On` が対応しているので `arm64` や `Windows` でもテストできるかもしれません。

### test.yaml でテスト

```yaml:.github/workflows/test.yaml
jobs:
  # ubuntu 24.04 でテスト
  ubuntu:
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v4
      # make 経由でシェルスクリプトを実行
      - run: make init
    ...
  # macos sequoia でテスト
  macos:
    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4
      - run: make init
    ...
  # docker でテスト
  docker:
    runs-on: ubuntu-latest
    steps:
      # docker製のアクションを使用
      - uses: docker/login-action@v3
      - uses: docker/setup-buildx-action@v3
      - uses: docker/setup-qemu-action@v3 # クロスプラットフォーム対応 遅い？
      - uses: docker/build-push-action@v5
    ...
  # windows でテスト
  windows:
    runs-on: windows-latest
    ...
```

---

## [Mise](https://mise.jdx.dev/)

### Mise を使用してプログラミングツールや CLI ツールを管理します

- `mise` は rust 製の runtime library の バージョン管理ツールです。

```sh
# ツールをインストール
mise use < tool@version >
# global にインストール
mise use -g < tool@version >
# インストールしたツールを確認
mise ls
# .mise.toml の指定ファイルを信頼
mise trust
# 環境変数を表示
mise set
```

- `mise` は `asdf` と 互換性があり `tool-versions` ファイルを使用できます。
- ディレクトリ毎にツールや環境変数を管理できます。
- `mise trust` で`.env` ファイルなどから 環境変数を読み込みます。
- `chezmoi` や `starship` などのライブラリもインストール、管理できます。
- 依存関係は自動で解決できないことがあるので注意が必要です。
- ツールのバージョンを指定してインストールしたり複数管理できます。
- `~/.config/mise/config.toml` でグローバルな設定ができます。
- `.mise.toml` でローカルな設定ができます。

## 環境変数

### 説明

- `.env` に必要な環境変数を設定します。
- `~/.config/mise/config.toml` で自動で読み込むファイル名を指定できます。

### 設定ファイルを作成

```sh
mise generate
vim .env
```

### ./.env に環境変数を記述

```sh
# .env 例
export VAR=hoge
# .gitignore で.env ファイルを除外
```

### ./.mise.toml で読み込むファイル名を指定

```toml:./.mise.toml
[env]
_.file = ".env*"
```

### 現在のディレクトリを信頼してファイルを読み込み

```sh
# 環境変数が反映される
mise trust
mise set

# 出力 hoge
```

---

## [Docker](https://docker.com/)

- `Dockerfile` で `Ubuntu-dev` のイメージをビルドしてプッシュ
- `Docker` コンテナ内で `xrdp` と `xfce4` を使用した `Ubuntu-dev` 環境を構築
- `Docker Compose` で複数のコンテナを起動
- `Dev Container` で使用
- `linux/amd64` `linux/arm64` Multi Platform 対応

```sh
cd .devcontainer
# コンテナをビルド
docker build -t ubuntu-dev .
# イメージをプッシュ
docker push ubuntu-dev
# コンテナを起動
docker compose up -d
# コンテナ内に入る
docker compose exec ubuntu /bin/bash
```

---

## [Multipass](https://multipass.run/)

### Multipass で cloud-init を使用して Ubuntu を起動

```sh
# オプションでカスタマイズ
# -n VM 名
# -c コア数
# -m メモリ
# -d ディスク
# --timeout タイムアウト時間 3600秒 = 1時間
# --mount マウント  from:to
# --cloud-init cloud-init の設定ファイルを指定

multipass launch \
  -n ubuntu \
  -c 4 \
  -m 8G \
  -d 42G \
  --timeout 43210 \
  --cloud-init cloud-init/multipass.yaml
```

---

## 📚 参考文献

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
