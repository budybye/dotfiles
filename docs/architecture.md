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

Makefile は dotfiles、開発環境（Docker / Multipass）、関連インフラのカテゴリ化されたコマンドインターフェースです。
ターゲット一覧と説明の正本は Makefile の `##` コメントで、`make help` で表示します。この文書には個別ターゲットを列挙しません。

### 設計原則

- **カテゴリ化**: `##@` 見出しで一般操作、セットアップ、開発、Docker、VM、Git、セキュリティ、クリーンアップ、情報表示に分ける
- **安全な実行**: `.ONESHELL` と `-euo pipefail` で失敗を握りつぶさない
- **設定可能な変数**: Docker は `DOCKER_*`、Multipass は `MP_*` を Makefile 先頭で定義する（値の正本は Makefile）。`DOCKER_*` は環境変数・引数で上書きできる
- **バージョン**: `DOTFILES_VERSION` は `git describe` の最新 semver タグ（無ければ `dev`）で、CI の `tag.yaml` と同じ系列

### 注意点

- `make test` / `make verify`: age passphrase が必要な環境では dry-run / verify が skipped になる。テンプレート構文検証の失敗は `make test` の失敗になる
- `make docker-build` / `make docker-slim-build`: `GITHUB_TOKEN` が必須（BuildKit secret として渡す）。ローカル build のみで、GHCR への push は CI が行う
- `make docker-run`: `docker-build` に依存し、ローカル build 済み image を `ubuntu-dev` として起動する。`make docker-ghcr-run` は公開済み image を pull して `ubuntu-dev-ghcr` として起動し、両者は共存できる
- `make age-keygen`: Mise direct-age 用の raw identity を `~/.config/mise/age.txt` に生成する。Chezmoi の passphrase とは別物で、既存ファイルがある場合は上書きせずに失敗する。Chezmoi encrypted files の passphrase は `chezmoi apply` 時に手動入力する
- `make clean`: `clean-docker` に加え、`.git` と `.jj` を除くリポジトリ配下の `*.tmp` / `*.log` を削除する
- `make clean-docker`: 未使用のコンテナ・イメージ・ボリュームを prune する（ボリュームも消える）
- `make git-commit`: `git add -A` → コミット → `git push origin main` を行う。jj 運用では使わない

## 開発ワークフロー

- **Makefile**: ビルド・管理スクリプト（設計は上記、ターゲット一覧は `make help` を参照）
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
