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
- **Mise runtime secrets**: direct age の identity パスを `age.key_file`（`~/.config/mise/age.txt`）で設定済み。age 暗号化した env 値はまだ使っていない（ROADMAP M2）
- **GitHub tokens**: CI の `MISE_GITHUB_TOKEN`（repo secret）、Docker build の `GITHUB_TOKEN`（BuildKit secret）、local の `gh` credential fallback
- **アクセス制御**: ファイル属性による権限管理

詳細は [セキュリティ](security.md) を参照。

### 移行計画の境界

- Chezmoi は passphrase/symmetric の暗号化ファイルとテンプレートを保持する
- Mise は package bootstrap と tool version を担当する（runtime age secret は ROADMAP M2 の未完了項目）
- profile の分離は未実装。現状は `make init` が CI・Docker・VM で同じ `.chezmoiscripts` を実行し、`.chezmoiignore` が除外するのは `DOCKER=true` の `linux/setup.sh` と `REMOTE_CONTAINERS=true` の `linux/gui.sh` / `linux/docker.sh` / `vscode.sh` だけ（詳細は「Bootstrap and profile boundaries」）。CI と Docker で `gui.sh` を走らせるのは意図的（Full image はデスクトップ image で、CI は `make init` 全体を検証する）
- Docker は SDDM と private key、GitHub token、Mise age identity を持たない
- 詳細な順序と未完了項目は [ROADMAP.md](../ROADMAP.md) に記録する

### クロスプラットフォーム設計

- **OS 検出**: `{{ .chezmoi.os }}`による自動検出
- **環境変数**: `GITHUB_ACTIONS`, `CODESPACES`, `DOCKER`等による環境別分岐
- **パッケージ管理**: OS 別のパッケージマネージャー統合

#### XDG Base Directory Specification

設定ファイルの配置は [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir/latest/) に沿う。このプロジェクトでは設定ファイルを `home/private_dot_config/` に置き、chezmoi は `XDG_CONFIG_HOME` の値にかかわらず常に `~/.config` へ配置する。

## 技術スタック

詳細は[技術スタック](./tech.md)を参照してください。
参照リンクの `active / optional / legacy` タグは補助情報で、採用判断の正本は `docs/tech.md` と実設定ファイル（`home/private_dot_config/mise/conf.d/tools.toml` など）です。

### コア技術

- **Chezmoi**: ドットファイル管理システム
- **Age**: Chezmoi passphrase と Mise direct-age
- **Mise**: ツール・package bootstrap・GitHub token resolution
- **XDG Base Directory**: 設定ファイル標準

### 対応環境

- **macOS**: Sequoia (15.0+)
- **Ubuntu**: 26.04 LTS
- **Docker**: コンテナ化環境
- **Multipass**: 軽量 VM 管理

## Makefile 設計

Makefile は dotfiles、開発環境（Docker / Multipass）、関連インフラのカテゴリ化されたコマンドインターフェースです。
ターゲット一覧と説明の正本は Makefile の `##` コメントで、`make help` で表示します。この文書には挙動に注意が必要なターゲットだけを「注意点」に書きます。

### 設計原則

- **カテゴリ化**: `##@` 見出しで一般操作、セットアップ、開発、Docker、VM、Git、セキュリティ、クリーンアップ、情報表示に分ける
- **安全な実行**: `.SHELLFLAGS := -ceuo pipefail` で失敗を握りつぶさない
- **設定可能な変数**: Docker は `DOCKER_*`、Multipass は `MP_*` を Makefile 先頭で定義する（値の正本は Makefile）。`DOCKER_*` は環境変数・引数で上書きできる
- **バージョン**: `DOTFILES_VERSION` は `git describe` の最新 semver タグ（無ければ `dev`）で、CI の `tag.yaml` と同じ系列

### 注意点

- `make test` / `make verify`: 暗号化ファイルと external を除外して実行するため age passphrase は不要。`make test` は現在の OS / profile で適用対象の template の描画エラー、`make verify` は適用先と source の差分で失敗する
- `make docker-build` / `make docker-slim-build`: `GITHUB_TOKEN` が必須（BuildKit secret として渡す）。ローカル build のみで、GHCR への push は CI が行う
- `make docker-run`: `docker-build` に依存し、ローカル build 済み image を `ubuntu-dev` として起動する。`make docker-ghcr-run` は公開済み image を pull して `ubuntu-dev-ghcr` として起動する。両者は同じ `DOCKER_PORTS`（`127.0.0.1:33389`）を使うため同時には起動できず、`.devcontainer/compose.yaml`（コンテナ名 `ubuntu-dev`、既定 33389）とも共存できない。`docker-pull` は同じ `$(DOCKER_IMAGE)` タグのローカル build を上書きする
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

- [Chezmoi 公式ドキュメント](https://www.chezmoi.io/user-guide/setup/)
- [Mise age secrets](https://mise.jdx.dev/environments/secrets/age.html)
- [Mise GitHub tokens](https://mise.jdx.dev/dev-tools/github-tokens.html)

## Bootstrap and profile boundaries

`make init` is the compatibility entry point:

```text
install.sh → chezmoi init --apply → platform bootstrap → Mise tools
```

| Profile | Package scope | GUI / service scope |
|---|---|---|
| workstation | full macOS or Ubuntu package set | local GUI and services allowed |
| ci | same scripts as workstation on the runner; no separate package set | Linux `gui.sh` and `setup.sh` run (not ignored, intentionally: CI exercises the whole `make init`) |
| docker | same Linux scripts plus Dockerfile apt packages; no separate package set | Full image: xfce4 / xorgxrdp / xrdp, `EXPOSE 3389`; `linux/setup.sh` ignored; Slim image Dockerfile installs no xrdp |

Separate ci / docker package profiles (`MISE_CONFIG_FILE`, `MISE_GLOBAL_CONFIG_FILE`) are not implemented; ROADMAP M8-6 tracks the split. Running `gui.sh` in CI and Docker is intentional, not a missing guard: the Full image is a desktop image, and none of the extra packages `gui.sh` installs depends on or recommends `light-locker` / `xscreensaver`, which the Dockerfile removes for RDP. Package definitions are `mise.toml` `[bootstrap.packages]` (`apt:`, `brew:`, `brew-cask:`; the `mas:` entries are not applied, because `brew bundle` and `--manager mas` need an App Store sign-in that the CI macOS runner lacks). The macOS `Brewfile` is a separate list read only by the `bb` / `bf` / `bcf` aliases (bootstrap no longer applies it), and the two lists differ; reconciling them is open (ROADMAP M2). Tool definitions are `mise/conf.d/tools.toml`.

## Ownership split (target state)

| Tool | Owns |
|---|---|
| Mise | tool versions, OS packages, macOS UI defaults, curl app installers, age-encrypted runtime env values, GitHub token resolution |
| Chezmoi | templated dotfiles, passphrase-encrypted files, SSH config, VS Code extensions, agent skills, snap / Windows, platform scripts, external resources |

`install.sh` does not install Mise today; Mise is installed by `run_once_before_age.sh.tmpl`, `darwin/run_onchange_after_bootstrap.sh.tmpl`, `linux/run_onchange_after_cli.sh.tmpl` and `cloud-init/multipass.yaml` (ROADMAP M2 makes `install.sh` the only entry). `packages.yaml` currently holds Windows `winget` / `scoop` and `curl:` entries only; snap is not managed, VS Code extension install is disabled in `run_onchange_after_vscode.sh.tmpl`, and no Mise env value is age-encrypted yet. Mise runtime age keys and the Chezmoi passphrase stay independent.

## Machine profile and GitHub identity

- A hostname → profile map (`desktop` / `minimal` / `darwin`) does not exist in `.chezmoidata` yet (ROADMAP short-term goal); the Linux GUI script runs on every Linux host except `REMOTE_CONTAINERS=true`.
- git / jj / Chezmoi data default to `budybye`; `~/Developer/dayjobdoor` and `~/Developer/boborder` switch identity through git `includeIf` and jj `[[--scope]]`, with SSH Hosts `github-dayjobdoor` / `github-boborder`. gh `hosts.yml` lists `budybye`, `dayjobdoor` and `boborder` with active user `boborder`; switch with `gh auth switch`. ROADMAP wants `budybye` as the gh default account (still open: the tracked `hosts.yml` has `user: boborder`) and says the default account must not be chosen by a path-based `includeIf`; that already holds, because `includeIf` only applies the org identities under `~/Developer/{dayjobdoor,boborder}`. The `dayjobdoor` key pair is tracked like the other accounts: the public key (`id_ed25519_dayjobdoor.pub.tmpl`) and the age-encrypted private key (`encrypted_private_id_ed25519_dayjobdoor.age`).

## VCS and template boundaries

- jj is the preferred local VCS; colocated Git remains for remotes, CI, and compatibility.
- `home/dot_local/bin/executable_jjj` owns the repository-specific jj workflow.
- Chezmoi Go templates use `{{-` / `-}}` only for intentional whitespace trimming; inline values normally omit trim markers.
- Detailed implementation order belongs in `ROADMAP.md`, not in this architecture reference.

## Remote desktop boundary

Ubuntu full GUI uses `xrdp + xorgxrdp + Xorg + XFCE`. The Docker Full image uses the same path (`EXPOSE 3389`, published on `127.0.0.1` by `make docker-run`); the Slim image Dockerfile installs no xrdp (`EXPOSE 22`). There is no systemd in containers and no native Wayland xrdp path. SDDM is only a local-login choice, never an xrdp prerequisite.
