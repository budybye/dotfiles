---
name: architecture
description: dotfiles アーキテクチャ・詳細設計
---

# アーキテクチャ設計 - Chezmoi Dotfiles Management System

## プロジェクト概要

このリポジトリは、**chezmoi**を使用した dotfiles 管理システムです。macOS と Ubuntu の設定ファイルを統合管理し、セキュリティとクロスプラットフォーム対応を重視しています。

## 設計方針

### アーキテクチャ原則

1. **セキュリティ優先設計**

   - 機密情報の暗号化（age）
   - Bitwarden desktop は macOS の任意パッケージ
   - SSH 鍵の安全な管理

2. **クロスプラットフォーム対応**

   - OS 固有設定の分離
   - テンプレート変数による環境別制御
   - XDG Base Directory Specification 準拠

3. **保守性と拡張性**
   - 明確なディレクトリ構造
   - モジュール化された設定
   - 一貫した命名規則

### ディレクトリ設計

詳細は[ディレクトリ構成](./directory.md)を参照してください。

- `home/`: chezmoi 管理下の設定ファイル
- `docs/`: プロジェクトドキュメント
- `.devcontainer/`: 開発環境設定
- `cloud-init/`: クラウド初期化設定

### セキュリティ設計

- **Chezmoi encrypted files**: age passphrase/symmetric
- **Mise runtime secrets**: direct age、`~/.config/mise/age.txt`
- **GitHub tokens**: CI の `GITHUB_TOKEN`、local の `gh` credential fallback
- **アクセス制御**: ファイル属性による権限管理

詳細は [セキュリティ](security.md) を参照。

### 移行計画の境界

- Chezmoi は passphrase/symmetric の暗号化ファイルとテンプレートを保持する
- Mise は package bootstrap、tool version、runtime age secret を担当する
- CI は CLI profile、Docker は CLI-only profile、Ubuntu VM は full GUI profile を使う
- Docker は SDDM と private key、GitHub token、Mise age identity を持たない
- 詳細な順序と未完了項目は [ROADMAP.md](../ROADMAP.md) に記録する

### クロスプラットフォーム設計

- **OS 検出**: `{{ .chezmoi.os }}`による自動検出
- **環境変数**: `GITHUB_ACTIONS`, `CODESPACES`, `DOCKER`等による環境別分岐
- **パッケージ管理**: OS 別のパッケージマネージャー統合

#### XDG Base Directory Specification

XDG Base Directory Specification は、Linux デスクトップ環境において、ユーザー固有のファイル（データ、設定、キャッシュなど）を適切な場所に配置するための標準仕様です。これにより、ホームディレクトリの散乱を防ぎ、一貫したファイル管理を実現します。

##### 主要なベースディレクトリ

1. **ユーザー固有のデータファイル**: `$XDG_DATA_HOME` (デフォルト: `$HOME/.local/share`)
2. **ユーザー固有の設定ファイル**: `$XDG_CONFIG_HOME` (デフォルト: `$HOME/.config`)
3. **ユーザー固有の状態データ**: `$XDG_STATE_HOME` (デフォルト: `$HOME/.local/state`)
4. **ユーザー固有の実行ファイル**: `$HOME/.local/bin`
5. **ユーザー固有のキャッシュデータ**: `$XDG_CACHE_HOME` (デフォルト: `$HOME/.cache`)
6. **ユーザー固有のランタイムファイル**: `$XDG_RUNTIME_DIR` (ログイン中のみ存在、再起動後削除)

##### システム全体の検索パス

1. **データファイル検索パス**: `$XDG_DATA_DIRS`
2. **設定ファイル検索パス**: `$XDG_CONFIG_DIRS`

##### 重要な規則

- すべてのパスは絶対パスでなければならない
- 優先順位: `$XDG_DATA_HOME` > `$XDG_DATA_DIRS`、`$XDG_CONFIG_HOME` > `$XDG_CONFIG_DIRS`
- 書き込み時にディレクトリが存在しない場合は、権限 0700 で作成を試行

##### 実装における活用

このプロジェクトでは、設定ファイルを`home/private_dot_config/`に配置し、chezmoi 適用時に`$XDG_CONFIG_HOME`（通常は`~/.config`）に配置されます。これにより：

- ホームディレクトリの整理が促進される
- アプリケーション間での統一されたファイル配置が実現される
- バックアップ効率が向上する（重要なファイルと一時ファイルの分離）
- セキュリティが向上する（ランタイムファイルの適切な権限管理）

参考: [XDG Base Directory Specification (公式)](https://specifications.freedesktop.org/basedir-spec/latest/)

## 技術スタック

詳細は[技術スタック](./tech.md)を参照してください。
参照リンクの `active / optional / legacy` タグは補助情報で、採用判断の正本は `docs/tech.md` と実設定ファイル（`home/private_dot_config/mise/config.toml` など）です。

### コア技術

- **Chezmoi**: ドットファイル管理システム
- **Age**: Chezmoi passphrase と Mise direct-age
- **Mise**: ツール・runtime secrets・GitHub token resolution
- **XDG Base Directory**: 設定ファイル標準

### 対応環境

- **macOS**: Sequoia (15.0+)
- **Ubuntu**: 24.04 LTS
- **Docker**: コンテナ化環境
- **Multipass**: 軽量 VM 管理

## Makefile 設計

Makefile は、dotfiles システム、開発環境、および関連インフラストラクチャを管理するためのカテゴリ化されたコマンドインターフェースを提供します。

### 設計原則

- **カテゴリ化**: コマンドが論理的にグループ分けされています（一般操作、セットアップ、開発、Docker、VM、Git、セキュリティ、クリーンアップ、情報表示）
- **エラーハンドリング**: 安全なコマンド実行と適切なエラー処理
- **設定可能な変数**: 簡単にカスタマイズ可能（`DOTFILES_VERSION`、`ARCH`、`OS`など）
- **依存関係管理**: ターゲット間の依存関係が明確
- **ヘルプ機能**: `make help` で全コマンドの説明を表示

### 主要カテゴリ

1. **一般操作**: `help`、`version`
2. **セットアップとインストール**: `init`、`update`、`apply`
3. **開発**: `check`、`test`、`completion`、`doctor`、`verify`
4. **Docker**: `docker-build`、`docker-slim-build`、`docker-run`、`docker-ghcr-run`、`docker-pull`、`docker-slim-pull`、`up`、`down`、`exec`、`logs`
5. **仮想マシン（Multipass）**: `vm-create`、`vm-info`、`vm-start`、`vm-stop`、`ssh`
6. **Git 操作**: `git-commit`、`git-status`
7. **セキュリティ**: `age-keygen`
8. **クリーンアップ**: `clean-docker`、`clean-vm`、`clean`
9. **情報表示**: `list-vms`、`list-containers`、`system-info`

### 設定変数

- `DOTFILES_VERSION`: `git describe` による最新 semver タグ（タグ無し時は `dev`）。CI の `tag.yaml` と同じ系列
- `ARCH`: システムアーキテクチャ（自動検出）
- `DOCKER_ARCH`: Docker 用アーキテクチャ（x86_64→amd64、aarch64→arm64 に変換）
- `OS`: オペレーティングシステム（自動検出）

#### Docker 設定変数

- `DOCKER_REGISTRY_IMAGE`: `ghcr.io/budybye/ubuntu-dev`
- `DOCKER_IMAGE`: `ghcr.io/budybye/ubuntu-dev:latest`
- `DOCKER_SLIM_IMAGE`: `ghcr.io/budybye/ubuntu-dev:slim`
- `DOCKER_DEV_IMAGE`: `ghcr.io/budybye/ubuntu-dev:dev`
- `DOCKER_CONTAINER`: `ubuntu-dev`
- `DOCKER_HOST`: `container`
- `DOCKER_PORTS`: `-p 127.0.0.1:33389:3389`
- `DOCKER_WORKDIR`: `/home/ubuntu`
- `DOCKER_USER`: `ubuntu`

#### Multipass 設定変数

- `MP_VM`: `ubuntu`
- `MP_CPUS`: `4`
- `MP_MEMORY`: `8G`
- `MP_DISK`: `42G`
- `MP_TIMEOUT`: `43210` seconds

### コマンドリファレンス

#### 一般操作

##### `help`

カテゴリ別に整理されたすべての利用可能コマンドでこのヘルプメッセージを表示します。

```sh
make help
```

##### `version`

dotfiles バージョン、OS、アーキテクチャを含むバージョン情報を表示します。

```sh
make version
```

#### セットアップとインストール

##### `init`

インストールスクリプトを実行して chezmoi で dotfiles を初期化します。

```sh
make init
```

##### `update`

`chezmoi update`を使用してリモートリポジトリから dotfiles を更新します。

```sh
make update
```

##### `apply`

`chezmoi apply`を使用して dotfiles の変更を適用します。

```sh
make apply
```

#### 開発

##### `check`

変更をプレビューするために`chezmoi diff`を実行して dotfiles 設定をチェックします。

```sh
make check
```

##### `test`

テンプレート構文の検証と `chezmoi apply --dry-run` を実行します。

```sh
make test
```

##### `completion`

chezmoi の zsh 補完スクリプトを標準出力に出力します。

```sh
make completion
```

##### `doctor`

chezmoi の健全性チェックを実行します。

```sh
make doctor
```

##### `verify`

chezmoi のスクリプト検証を実行します。age/Bitwarden が必要な環境では skipped になる場合があります。

```sh
make verify
```

#### Docker コマンド

##### `docker-build`

`.devcontainer/`ディレクトリから Full image をローカル build します。タグは `ghcr.io/budybye/ubuntu-dev:latest` です。GHCR への push は CI が行います。

```sh
make docker-build
```

##### `docker-slim-build`

`.devcontainer/slim.Dockerfile` から Slim CLI image をローカル build します。タグは `ghcr.io/budybye/ubuntu-dev:slim` です。

```sh
make docker-slim-build
```

##### `docker-run`

ローカル build 済みの Full image を `ubuntu-dev` container として起動します。

```sh
make docker-run
```

##### `docker-ghcr-run`

公開済みの `ghcr.io/budybye/ubuntu-dev:latest` を pull して、ローカル build とは別の `ubuntu-dev-ghcr` container として実行します。

```sh
make docker-ghcr-run
```

##### `docker-pull` / `docker-slim-pull`

公開済みの Full / Slim image を pull します。起動は行いません。


##### `up`

`.devcontainer/`ディレクトリから Docker Compose サービスを開始します。

```sh
make up
```

##### `down`

Docker Compose サービスを停止します。

```sh
make down
```

##### `exec`

実行中の Docker コンテナで bash を実行します。

```sh
make exec
```

##### `logs`

フォローモードで Docker コンテナのログを表示します。

```sh
make logs
```

#### 仮想マシンコマンド (Multipass)

##### `vm-create`

cloud-init 設定で Multipass VM を作成します。

```sh
make vm-create
```

##### `vm-info`

ステータス、IP、リソース使用量を含む詳細な VM 情報を表示します。

```sh
make vm-info
```

##### `vm-start`

Multipass VM を開始します。

```sh
make vm-start
```

##### `vm-stop`

Multipass VM を停止します。

```sh
make vm-stop
```

##### `ssh`

設定された SSH 設定を使用して Multipass VM に SSH 接続します。

```sh
make ssh
```

#### Git 操作

##### `git-commit`

コミットメッセージを必須とした対話型コミット・プッシュ。空メッセージの場合は中止します。

```sh
make git-commit
```

##### `git-status`

現在の git リポジトリのステータスを表示します。

```sh
make git-status
```

#### セキュリティコマンド

##### `age-keygen`

Mise direct-age 用の raw identity を生成します。Chezmoi の passphrase とは別です。

```sh
make age-keygen
```

Chezmoi encrypted files の passphrase は `chezmoi decrypt` / `chezmoi apply` 実行時に手動入力します。

#### クリーンアップコマンド

##### `clean-docker`

コンテナ、イメージ、ボリュームを含む Docker リソースをクリーンアップします。

```sh
make clean-docker
```

##### `clean-vm`

Multipass VM を削除してパージします。

```sh
make clean-vm
```

##### `clean`

すべての一時リソースとファイルをクリーンアップします。

```sh
make clean
```

#### 情報コマンド

##### `list-vms`

ステータス情報と共にすべての Multipass VM を一覧表示します。

```sh
make list-vms
```

##### `list-containers`

すべての Docker コンテナ（実行中と停止中）を一覧表示します。

```sh
make list-containers
```

##### `system-info`

総合的なシステム情報を表示します。

```sh
make system-info
```

## 開発ワークフロー

- **Makefile**: ビルド・管理スクリプト（設計とコマンドリファレンスは上記を参照）
- **GitHub Actions**: CI/CD 自動化
- **Dev Containers**: 開発環境のコンテナ化

## 関連ドキュメント

- [要件定義](./requirements.md)
- [ロードマップ](../ROADMAP.md)
- [技術スタック](./tech.md) - パッケージ管理
- [ディレクトリ構成](./directory.md) - Chezmoi スクリプト設計

## 参考資料

- [Chezmoi 公式ドキュメント](https://chezmoi.io/user-guide/)
- [Mise age secrets](https://mise.jdx.dev/environments/secrets/age.html)
- [Mise GitHub tokens](https://mise.jdx.dev/dev-tools/github-tokens.html)
- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/)

## Bootstrap and profile boundaries

`make init` is the compatibility entry point:

```text
install.sh → chezmoi apply → platform bootstrap → Mise tools
```

| Profile | Package scope | GUI / service scope |
|---|---|---|
| workstation | full macOS or Ubuntu package set | local GUI and services allowed |
| ci | macOS manager set or Linux CLI packages | Linux GUI and system services excluded |
| docker | Linux CLI packages | no SDDM, xrdp, PipeWire, or systemd |

`MISE_CONFIG_FILE` selects a CI or Docker package profile. `MISE_GLOBAL_CONFIG_FILE` points tool installation at `mise/config.toml`. Package profiles and tool definitions must not be mixed.

## VCS and template boundaries

- jj is the preferred local VCS; colocated Git remains for remotes, CI, and compatibility.
- `home/dot_local/bin/executable_jjj` owns the repository-specific jj workflow.
- Chezmoi Go templates use `{{-` / `-}}` only for intentional whitespace trimming; inline values normally omit trim markers.
- Detailed implementation order belongs in `ROADMAP.md` and optional OpenSpec changes, not in this architecture reference.

## Remote desktop boundary

Ubuntu full GUI uses `xrdp + xorgxrdp + Xorg + XFCE`. Docker remains CLI-first: no display manager, systemd service, or native Wayland xrdp path. SDDM is only a local-login choice, never an xrdp prerequisite.
