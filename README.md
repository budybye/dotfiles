<link href="./style.css" rel="stylesheet"></link>

# dotfiles

v.0.1.1

## 概要

#### このリポジトリは、**Dotfiles** の管理を目的としています。様々なツールや設定ファイルを統合し、効率的な開発環境を構築します。

#### MacOS と Ubuntu 24.04 で Github Actions で chezmoi をインストールしてテストして、Dotfiles を管理します。

今後は Windows でも WSL2 と Windows 用の設定ファイルを追加で管理します。


## 目次

1. [XDG ディレクトリ構成](#xdg-ディレクトリ構成)
2. [環境設定](#環境設定)
3. [Chezmoi の使用](#chezmoi-の使用)
4. [Mise の使用](#mise-の使用)
5. [シェル設定](#シェル設定)
6. [エイリアス設定](#エイリアス設定)
7. [各種設定ファイル](#各種設定ファイル)
8. [Docker と xrdp の設定](#docker-と-xrdp-の設定)

---

## XDG ディレクトリ構成

XDG Base Directory Specification に基づくディレクトリの設定を行います。

```:~/.profile/
XDG_CONFIG_HOME=${HOME}/.config

XDG_DATA_HOME=${HOME}/.local/share

XDG_CACHE_HOME=${HOME}/.cache

XDG_STATE_HOME=${HOME}/.local/state
XDG_DATA_DIRS=/usr/local/share:/usr/share:${HOME}/data
XDG_CONFIG_DIRS=/etc/xdg

...
```

### XDG Base Directory Specification

- **XDG_CONFIG_HOME**: ユーザー固有の設定ファイルの格納先。
- **XDG_DATA_HOME**: ユーザー固有のデータファイルの格納先。
- **XDG_CACHE_HOME**: ユーザー固有のキャッシュファイルの格納先。
- **XDG_STATE_HOME**: ユーザー固有の状態ファイルの格納先。
- **XDG_DATA_DIRS**: システム全体のデータファイルの検索パス。
- **XDG_CONFIG_DIRS**: システム全体の設定ファイルの検索パス。

---

## 環境設定

設定ファイルを作成
```sh
touch ./.mise.toml
touch ./.env
```
./.env に環境変数を記述
```sh:./.env
export VAR=hoge
```
./.mise.toml で読み込むファイル名を指定
```toml:./.mise.toml
[env]
'_'.file = ".env"

```
現在のディレクトリを信頼してファイルを読み込み
```
mise trust
echo $VAR
# 環境変数が反映される
hoge
```
./.gitignore でファイルを除外
```txt:./.gitignore
.env
```

### 説明

`.env` ファイルを作成し、必要な環境変数を設定します。

---

## Chezmoi の使用

Chezmoi を使用して Dotfiles を管理します。

```sh
# 初期化
chezmoi init --apply budybye

# cd コマンドで移動 ~/.local/share/chezmoi
chezmoi cd
# 変更を適用
chezmoi apply < option Filename >
# ファイルを追加
chezmoi add --follow < Filename >
# ファイルの属性を変更
chezmoi chattr < Filename >
```

### 説明

- `init`: Chezmoi のリポジトリを初期化し、設定を適用します。
- `cd`: Chezmoi の管理ディレクトリに移動します。
- `apply`: 指定したオプションファイルを適用します。
- `add`: ファイルを Chezmoi の管理対象に追加します。
- `chattr`: ファイルの属性を変更します。

---

## Mise の使用

Mise を使用してツールを管理します。

```sh
# ツールをインストール
mise use < tool@version >

# インストールしたツールを確認
mise ls

# .mise.toml を信頼
mise trust
```

### 説明

- `use`: 特定のツールとバージョンを使用します。
- `ls`: インストールされているツールの一覧を表示します。
- `trust`: 信頼できるリポジトリを設定します。

---


```
~/
├── multipass.yaml                  # Multipass のcloud-init ファイル
├── .chezmoiignore                  # chezmoi の除外ファイル
├── .zshrc                          # zsh の設定ファイル
├── .zshenv                         # zsh の環境変数
├── .profile                        # ログインシェルに共通で読み込まれるファイル
├── .bashrc                         # bash の設定ファイル
├── .bash_profile                   # bash の環境変数
├── .aliases                        # エイリアスの設定ファイル
├── .Makefile                       # Make で シェルスクリプトを設定管理 make sense
├── .mise.toml                      # mise の設定ファイル .env を読み込む
├── .env                            # 環境変数の設定ファイル
├── .config                         # XDG ディレクトリ構成に基づく設定ファイル
│   ├── .editorconfig               # editorconfig の設定ファイル
│   ├── Brewfile                    # Brewfile
│   ├── starship.toml               # starship の設定ファイル
│   ├── sheldon                    
│   │   └── plugins.toml            # sheldon のプラグインの設定ファイル
│   ├── aquaproj-aqua              
│   │   └── aqua.yaml               # aqua の設定ファイル
│   ├── byobu                      
│   │   └── .tmux.conf              # byobu の設定ファイル
│   ├── vscode                     
│   │   ├── extensions.json         # VSCode の拡張機能の設定ファイル
│   │   ├── User
│   │   │   ├── setting.json        # VSCode の設定ファイル
│   │   │   └── keybindings.json    # VSCode のキーバインド設定ファイル
│   ├── git                         
│   │   ├── config                  # Git の設定ファイル
│   │   ├── ignore                  # Git の無視ファイルの設定ファイル
│   │   ├── commit.template         # Git のコミットメッセージのテンプレート
│   │   └── user.conf               # Git のユーザー設定ファイル
│   ├── tabby                       
│   │   └── config.yaml             # tabby の設定ファイル
│   ├── vim                        
│   │   └── vimrc                   # vim の設定ファイル
│   ├── fcitx5                      
│   │   └── config                  # fcitx5 の設定ファイル
│   ├── fusuma                      
│   │   └── config.yml              # fusuma の設定ファイル
│   ├── neofetch                    
│   │   └── config.conf             # neofetch の設定ファイル
│   ├── fish
│   │   └── config.fish             # fish の設定ファイル
│   ├── mpd
│   │   └── mpd.conf                # mpd の設定ファイル
│   └── ncmpcpp
│       └── config                  # ncmpcpp の設定ファイル
│   
├── .local                          # ローカルユーザーディレクトリ
│   ├── share
│   │   ├── fonts                   # フォントのディレクトリ
│   │   ├── backgrounds             # 壁紙のディレクトリ
│   │   └── themes                  # テーマのディレクトリ
│   └── bin
│       ├── init.sh                 # Chezmoi の初期化スクリプト make init
│       ├── install.sh              # Ubuntu のインストールスクリプト make install
│       ├── setup.sh                # Ubuntu のセットアップスクリプト make setup
│       ├── bootstrap.sh            # MacOS のブートストラップスクリプト make bootstrap
│       ├── defaults.sh             # MacOS のデフォルトスクリプト make defaults
│       └── codex.sh                # VSCode のスクリプト make code
│
├── .devcontainer                   
│    ├── .devcontainer.json         # devcontainer の設定ファイル
│    ├── Dockerfile                 # Dockerfile
│    └── docker-compose.yaml        # docker-compose の設定ファイル
│
├── .github                         
│    ├── workflows                 
│    └── .test.yaml                 # Github Actions のテストの設定ファイル
├── data                            # データのディレクトリ
├── etc...                          # その他
```

## コメント

- **シェル設定**: シェルの動作や環境を設定するためのファイル群。
- **エイリアス設定**: よく使うコマンドの短縮形を定義するファイル。
- **各種設定ファイル**: 様々なツールやアプリケーションの設定を管理するためのファイル。
- **.local/share**: ユーザーがインストールしたフォントや壁紙などの共有リソースを格納するディレクトリ。

このツリー構造を参考に、ドットファイルの管理を行うことで、環境の一貫性を保ちながら効率的に作業を進めることができます。

---

## Docker と Multipass の設定
Dockerfile, cloud-init の仮想環境で
xrdp で接続できる Ubuntu Desktop 環境の設定

### Multipass の cloud-init
Multipass で cloud-init を使用して Ubuntu を起動
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
    -m 4G \
    -d 40G \
    --timeout 3600 \
    --mount ${HOME}/data:/home/ubuntu/mount \
    --cloud-init ${HOME}/multipass.yaml
```

### xrdp と Docker の設定
Docker コンテナ内で xrdp と xfce を使用した Ubuntu 環境を構築
```sh
# コンテナをビルド
docker build -t ubuntu-xrdp .
# イメージをプッシュ
docker push ubuntu-xrdp

# コンテナを起動
docker compose up -d
# コンテナ内に入る
docker compose exec ubuntu /bin/bash
```
