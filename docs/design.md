---
name: design
description: dotfiles 詳細設計
---

# 設計書 - Chezmoi Dotfiles Management System

## プロジェクト概要

このリポジトリは、**chezmoi**を使用した dotfiles 管理システムです。macOS と Ubuntu の設定ファイルを統合管理し、セキュリティとクロスプラットフォーム対応を重視しています。

## 設計方針

### アーキテクチャ原則

1. **セキュリティ優先設計**

   - 機密情報の暗号化（age）
   - パスワードマネージャー統合
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

- **暗号化**: `*.age`拡張子で age 暗号化
- **シークレット管理**: Bitwarden/1Password CLI 経由
- **アクセス制御**: ファイル属性による権限管理

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

### コア技術

- **Chezmoi**: ドットファイル管理システム
- **Age**: モダン暗号化ツール
- **Bitwarden CLI**: シークレット管理
- **XDG Base Directory**: 設定ファイル標準

### 対応環境

- **macOS**: Sequoia (14.0+)
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
3. **開発**: `check`、`test`
4. **Docker**: `docker-build`、`docker-run`、`up`、`down`、`exec`、`logs`
5. **仮想マシン（Multipass）**: `vm-create`、`vm-info`、`vm-start`、`vm-stop`、`ssh`
6. **Git 操作**: `git-commit`、`git-status`
7. **セキュリティ**: `age-keygen`、`bw-unlock`
8. **クリーンアップ**: `clean-docker`、`clean-vm`、`clean`
9. **情報表示**: `list-vms`、`list-containers`、`system-info`

### 設定変数

- `DOTFILES_VERSION`: 現在のバージョン (0.7.54)
- `ARCH`: システムアーキテクチャ（自動検出）
- `OS`: オペレーティングシステム（自動検出）

#### Docker 設定変数

- `DOCKER_IMAGE`: `ubuntu-dev`
- `DOCKER_CONTAINER`: `ubuntu-dev`
- `DOCKER_HOST`: `docker`
- `DOCKER_PORTS`: `-p 33389:3389 -p 2222:22`
- `DOCKER_WORKDIR`: `/home/dev`
- `DOCKER_USER`: `dev`

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

将来のテストスイート実装のプレースホルダーです。

```sh
make test
```

#### Docker コマンド

##### `docker-build`

`.devcontainer/`ディレクトリから Docker イメージをビルドします。

```sh
make docker-build
```

##### `docker-run` / `docker`

完全設定で Docker コンテナをビルドして実行します。

```sh
make docker-run
# or
make docker
```

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

##### `vm-create` / `ubuntu`

cloud-init 設定で Multipass VM を作成します。

```sh
make vm-create
# or
make ubuntu
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

##### `git-commit` / `git`

自動ステージングとプッシュを伴う対話型コミットプロセス。

```sh
make git-commit
# or
make git
```

##### `git-status`

現在の git リポジトリのステータスを表示します。

```sh
make git-status
```

#### セキュリティコマンド

##### `age-keygen` / `age`

パスフレーズ保護付きの新しい age 暗号化キーを生成します。

```sh
make age-keygen
# or
make age
```

##### `bw-unlock`

Bitwarden vault をアンロックし、シーサン環境変数を設定します。

```sh
make bw-unlock
```

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
- [タスク管理](./tasks.md)
- [技術スタック](./tech.md) - パッケージ管理
- [ディレクトリ構成](./directory.md) - Chezmoi スクリプト設計

## 参考資料

- [Chezmoi 公式ドキュメント](https://chezmoi.io/user-guide/)
- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/)
- [Age 暗号化ツール](https://age-encryption.org/)
- [Bitwarden CLI](https://bitwarden.com/help/cli/)
