<link href="./style.css" rel="stylesheet"></link>

# dotfiles

v.0.1.1

## 概要

このリポジトリは、**Dotfiles** の管理を目的としています。様々なツールや設定ファイルを統合し、効率的な開発環境を構築します。

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

```:~/.config/mise/config.toml
# mise の設定ファイル
./.mise.toml

~/.config/mise.toml

~/.config/mise/config.toml
```

### 説明

- `use`: 特定のツールとバージョンを使用します。
- `ls`: インストールされているツールの一覧を表示します。
- `trust`: 信頼できるリポジトリを設定します。

---

## シェル設定

シェルの設定ファイルを管理します。

```:~/
# シェルの設定ファイル
~/.zshrc
# シェルの環境変数
~/.zshenv
# ログインシェルに共通で読み込まれるファイル
~/.profile
# bash の設定ファイル
~/.bashrc
# bash の環境変数
~/.bash_profile
```

---

## エイリアス設定

便利なコマンドエイリアスを設定します。

```:~/.aliases
# zsh && bash
# エイリアスの設定ファイル
~/.aliases
```

---

## 各種設定ファイル

各種ツールの設定ファイルを管理します。

### starship

```:~/.config/starship.toml
# starship の設定ファイル
~/.config/starship.toml
```

### sheldon

```:~/.config/sheldon/plugins.toml
# sheldon のプラグインの設定ファイル
~/.config/sheldon/plugins.toml
```

### aqua

```:~/.config/aquaproj-aqua/aqua.yaml
# aqua の設定ファイル
~/.config/aquaproj-aqua/aqua.yaml
```

### byobu

```:~/.config/byobu/.tmux.conf
# byobu の設定ファイル
~/.config/byobu/.tmux.conf
```

### VSCodium

```:~/.config/vscode
# VSCodium の設定ファイル
~/.config/vscode/user-date/User/setting.json
# VSCodium の拡張機能の設定ファイル
~/.config/vscode/extntions.json
```

### Git

```:~/.config/git
# Git の設定ファイル
~/.config/git/config
# Git のユーザー設定ファイル
~/.config/git/user.conf
# Git の無視ファイルの設定ファイル
~/.config/git/ignore
# Git のコミットメッセージのテンプレート
~/.config/git/commit.template
```

### tabby

```:~/.config/tabby/config.yaml
# tabby の設定ファイル
~/.config/tabby/config.yaml
```

### editorconfig

```:~/.config/.editorconfig
# editorconfig の設定ファイル
~/.config/.editorconfig
```

### vim

```:~/.config/vim/vimrc
# vim の設定ファイル
~/.config/vim/vimrc
```

### fcitx5

```:~/.config/fcitx5/config
# fcitx5 の設定ファイル
~/.config/fcitx5/config
```

### fusuma

```:~/.config/fusuma/config.yml
# fusuma の設定ファイル
~/.config/fusuma/config.yml
```

### neofetch

```:~/.config/neofetch/config.conf
# neofetch の設定ファイル
~/.config/neofetch/config.conf
```

### Fonts

```:~/.local/share/fonts
~/.local/share/fonts
```

### Brewfile

```:~/.config/Brewfile
~/.config/Brewfile
```

---

## Docker と Multipass の設定
Dockerfile, cloud-init の仮想環境で
xrdp で接続できる Ubuntu Desktop 環境の設定

### Multipass の cloud-init
Multipass で cloud-init を使用して Ubuntu を起動
```sh
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
docekr compose up
```
