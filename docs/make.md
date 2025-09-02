# Makefileコマンドリファレンス

## 概要

Makefileは、dotfilesシステム、開発環境、および関連インフラストラクチャを管理するためのカテゴリ化されたコマンドインターフェースを提供します。

## 設定変数

- `DOTFILES_VERSION`: 現在のバージョン (0.7.54)
- `ARCH`: システムアーキテクチャ（自動検出）
- `OS`: オペレーティングシステム（自動検出）

## コマンドカテゴリ

### 一般操作

#### `help`

カテゴリ別に整理されたすべての利用可能コマンドでこのヘルプメッセージを表示します。

```sh
make help
```

#### `version`

dotfilesバージョン、OS、アーキテクチャを含むバージョン情報を表示します。

```sh
make version
```

### セットアップとインストール

#### `init`

インストールスクリプトを実行してchezmoiでdotfilesを初期化します。

```sh
make init
```

#### `update`

`chezmoi update`を使用してリモートリポジトリからdotfilesを更新します。

```sh
make update
```

#### `apply`

`chezmoi apply`を使用してdotfilesの変更を適用します。

```sh
make apply
```

### 開発

#### `check`

変更をプレビューするために`chezmoi diff`を実行してdotfiles設定をチェックします。

```sh
make check
```

#### `test`

将来のテストスイート実装のプレースホルダーです。

```sh
make test
```

## Dockerコマンド

### 設定

- **DOCKER_IMAGE**: `ubuntu-dev`
- **DOCKER_CONTAINER**: `ubuntu-dev`
- **DOCKER_HOST**: `docker`
- **DOCKER_PORTS**: `-p 33389:3389 -p 2222:22`
- **DOCKER_WORKDIR**: `/home/dev`
- **DOCKER_USER**: `dev`

### Commands

#### `docker-build`

`.devcontainer/`ディレクトリからDockerイメージをビルドします。

```sh
make docker-build
```

#### `docker-run` / `docker`

完全設定でDockerコンテナをビルドして実行します。

```sh
make docker-run
# or
make docker
```

機能：

- TTY付きの対話型デタッチモード
- 特権アクセス
- プラットフォーム固有アーキテクチャサポート
- 環境変数`DOCKER=true`
- RDP (33389:3389) とSSH (2222:22) のポートフォワーディング

#### `up`

`.devcontainer/`ディレクトリからDocker Composeサービスを開始します。

```sh
make up
```

#### `down`

Docker Composeサービスを停止します。

```sh
make down
```

#### `exec`

実行中のDockerコンテナでbashを実行します。

```sh
make exec
```

#### `logs`

フォローモードでDockerコンテナのログを表示します。

```sh
make logs
```

## 仮想マシンコマンド (Multipass)

### 設定

- **MP_VM**: `ubuntu`
- **MP_CPUS**: `4`
- **MP_MEMORY**: `8G`
- **MP_DISK**: `42G`
- **MP_TIMEOUT**: `43210` seconds

### コマンド

#### `vm-create` / `ubuntu`

cloud-init設定でMultipass VMを作成します。

```sh
make vm-create
# or
make ubuntu
```

機能：

- 初期化に`cloud-init/multipass.yaml`を使用
- 作成後にcloud-initログの最後5行を表示

#### `vm-info`

ステータス、IP、リソース使用量を含む詳細なVM情報を表示します。

```sh
make vm-info
```

#### `vm-start`

Multipass VMを開始します。

```sh
make vm-start
```

#### `vm-stop`

Multipass VMを停止します。

```sh
make vm-stop
```

#### `ssh`

設定されたSSH設定を使用してMultipass VMにSSH接続します。

```sh
make ssh
```

## Git操作

### `git-commit` / `git`

自動ステージングとプッシュを伴う対話型コミットプロセス。

```sh
make git-commit
# or
make git
```

機能：

- `git add -A`ですべての変更をステージ
- コミット前にステータスを表示
- 対話型コミットメッセージ入力
- タイムスタンプ付き自動コミットオプション
- mainブランチへの自動プッシュ

#### `git-status`

現在のgitリポジトリのステータスを表示します。

```sh
make git-status
```

## セキュリティと暗号化

### `age-keygen` / `age`

パスフレーズ保護付きの新しいage暗号化キーを生成します。

```sh
make age-keygen
# or
make age
```

暗号化されたキーを`./home/key.txt.age`に保存します。

#### `bw-unlock`

Bitwarden vaultをアンロックし、シーサン環境変数を設定します。

```sh
make bw-unlock
```

## クリーンアップコマンド

### `clean-docker`

コンテナ、イメージ、ボリュームを含むDockerリソースをクリーンアップします。

```sh
make clean-docker
```

操作：

- 未使用コンテナを削除
- 未使用イメージを削除
- 未使用ボリュームを削除
- エラー耐性実行

#### `clean-vm`

Multipass VMを削除してパージします。

```sh
make clean-vm
```

#### `clean`

すべての一時リソースとファイルをクリーンアップします。

```sh
make clean
```

操作：

- `clean-docker`を呼び出し
- `*.tmp`ファイルを削除
- `*.log`ファイルを削除

## 情報コマンド

### `list-vms`

ステータス情報と共にすべてのMultipass VMを一覧表示します。

```sh
make list-vms
```

#### `list-containers`

すべてのDockerコンテナ（実行中と停止中）を一覧表示します。

```sh
make list-containers
```

#### `system-info`

総合的なシステム情報を表示します。

```sh
make system-info
```

表示される情報：

- オペレーティングシステム
- アーキテクチャ
- シェル
- Dotfilesバージョン
- Chezmoiバージョン（インストール済みの場合）
- Dockerバージョン（インストール済みの場合）
- Multipassバージョン（インストール済みの場合）

## Makefileベストプラクティス

### 変数代入

- 即座変数代入に`:=`を使用
- システム変数の自動検出 (`ARCH`, `OS`)

### エラーハンドリング

- エラー耐性操作に`|| true`を使用
- 適切なシェルフラグ: `-ceuo pipefail`

### ドキュメンテーション

- すべてのターゲットにヘルプシステム用の`##`コメントを含む
- `##@`形式のカテゴリヘッダー
- 一貫したターゲット命名規則

### PHONYターゲット

同名ファイルとの競合を回避するため、すべてのターゲットに`.PHONY`がマークされています。

## 使用例

### 初期セットアップ

```sh
# dotfilesシステムを初期化
make init

# 設定をチェック
make check

# 変更を適用
make apply
```

### 開発環境

```sh
# 開発用VMを作成
make vm-create

# またはDocker環境を使用
make docker-run

# 環境に接続
make ssh          # VM用
make exec         # Docker用
```

### メンテナンス

```sh
# dotfilesを更新
make update

# リソースをクリーンアップ
make clean

# システム情報をチェック
make system-info
```
