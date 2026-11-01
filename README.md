# dotfiles

Chezmoi で管理する個人 dotfiles。macOS と Ubuntu の設定を統合し、XDG Base Directory に沿って配置します。

## 管理対象

- シェル、Git、エディタ、ターミナルの設定
- Mise によるランタイムと CLI ツール
- macOS と Ubuntu のパッケージ、デスクトップ設定
- Docker、Dev Container、Multipass の開発環境
- age による暗号化設定とシークレット管理

## 初期化

### リモートリポジトリから初期化

`curl` または `wget` を用意して、次を実行します。

```sh
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply budybye
```

### ローカルチェックアウトから初期化

```sh
git clone git@github.com:budybye/dotfiles.git ~/dotfiles
cd ~/dotfiles
make init
```

`make init` は `install.sh` を実行します。`~/dotfiles` を checkout への symlink として作り（別の場所を指していれば異常終了）、それを Chezmoi の source directory として登録します。実体の source tree は `.chezmoiroot` により `home/` です。リモートから初期化した場合の source directory は `~/.local/share/chezmoi` になります。

配置は `mode = "symlink"` です。テンプレートと暗号化ファイル以外は repo の `home/` 配下への symlink になるため、適用先のファイルを編集（またはアプリが書き換え）すると repo の作業ツリーを直接変更します。

## よく使うコマンド

```sh
# 設定を更新して適用
make update
make apply

# 差分、テンプレート、スクリプトを確認
make check
make test
make verify
make doctor

# 利用可能な target を表示
make help
```

`make check` は `chezmoi diff`、`make test` は一時 destination への `chezmoi apply --dry-run`（現在の OS / profile で適用対象の template を描画し、失敗すれば異常終了）、`make verify` は適用先と source の差分検出（差分があれば失敗）を実行します。

## Docker

`.devcontainer/` には Full GUI image と Slim CLI image の Dockerfile があります。Full image は XFCE と xrdp、Slim image は SSH と CLI ツールを含みます。CI は `linux/amd64` と `linux/arm64` の image を GHCR に公開します。

```sh
# ローカルで build（GHCR と同じタグ形式で保存するだけ。push は CI）
make docker-build
make docker-slim-build

# 公開済み GHCR image を pull して `ubuntu-dev-ghcr` で起動（image タグはローカル build と共通で、pull で上書きされる）
make docker-ghcr-run

# Full image を build してから起動（毎回 rebuild する）
make docker-run

# Compose service を起動・停止
make up
make down

# 起動中の container に接続
make exec
make logs
```

公開済み image の pull だけを行う場合は `make docker-pull` または `make docker-slim-pull` を使います。`docker-ghcr-run` は `ubuntu-dev-ghcr` という別 container 名で起動します。`make up`（Compose）と `make docker-run` は同じ container 名 `ubuntu-dev` と port 33389 を使うため同時には起動できません。`make exec` / `make logs` は `ubuntu-dev` を対象にします。

Compose の RDP port は localhost に bind します（SSH port の行はコメントアウト中）。remote access が必要な場合は VPN または Zero Trust tunnel を使います。

### Docker build の GitHub token

Docker build は dotfiles を clone して `make init` を実行します。clone 元は作業コピーではなく GitHub 上の `DOTFILES_REF`（既定 `main`）で、未 push の変更は image に入りません。Mise が GitHub の tool metadata を取得するため、local build では `GITHUB_TOKEN` を設定してください。

```sh
# GitHub CLI の認証済み token を一時的に渡す
GITHUB_TOKEN="$(gh auth token)" make docker-build
GITHUB_TOKEN="$(gh auth token)" make docker-slim-build
GITHUB_TOKEN="$(gh auth token)" make up
```

GitHub Actions では workflow の `secrets.GITHUB_TOKEN` を BuildKit secret として渡します。token を `.env`、Dockerfile の `ARG` / `ENV`、image layer に保存しないでください。`.env` と `.devcontainer/.env` は `.gitignore` 済み（追跡されるのは `.env.example` のみ）ですが、平文のため使いません。ルートの `mise.toml` の `[env] _.file = '.env'` はコメントアウトしてあり、mise は `.env` を自動では読み込みません（グローバルの `env_file` も使いません）。`make docker-*` は環境変数 `GITHUB_TOKEN` を要求します。

## Multipass

```sh
make vm-create
make vm-start
make ssh
make vm-info
make vm-stop
make clean-vm
```

VM は chezmoi を導入して dotfiles を `/home/ubuntu/dotfiles` に clone するところまでです。適用は VM 内で `make init` を手動実行します。

## OrbStack

```sh
orb create ubuntu orb-dev -c cloud-init/orbstack.yaml
orb -m orb-dev
```

OrbStack用のcloud-initはCLI中心で、xrdpやデスクトップ環境を含めません。package を入れるだけで dotfiles は適用しないため、machine 内で clone して `make init` を手動実行します。

## 対応プラットフォーム

- macOS Sequoia 15 以降
- Ubuntu 26.04 LTS
- Docker
- Multipass
- OrbStack

WSL2、Windows、FreeBSD は将来対応予定です。対応範囲と package 要件は [要件定義](docs/requirements.md) を参照してください。

## 構成

- `home/`: Chezmoi の source tree。設定は XDG 配下へ配置します
- `home/.chezmoidata/`: OS、package、環境差分のデータ
- `home/private_dot_config/mise/`: Mise の tool 設定
- `.devcontainer/`: Dockerfile、Compose、Dev Container 設定
- `.github/workflows/`: test、release、GHCR build、IPFS pin workflow
- `docs/`: 設計、運用、セキュリティ、トラブルシューティング

## ドキュメント

| ドキュメント | 内容 |
| --- | --- |
| [要件定義](docs/requirements.md) | 目的、制約、対応範囲 |
| [アーキテクチャ](docs/architecture.md) | Chezmoi、Mise、bootstrap、レイヤー設計 |
| [検証ガイド](docs/testing.md) | ローカル、CI、OS別の検証 |
| [技術スタック](docs/tech.md) | 技術選定と設定の正本 |
| [ディレクトリ構成](docs/directory.md) | Chezmoi の配置と命名規則 |
| [セキュリティ](docs/security.md) | age、SSH、secret、CI |
| [環境差の注意点](docs/problems.md) | platform 差分と troubleshooting |
| [参考文献](docs/references.md) | 公式 docs と repository |
| [ROADMAP](ROADMAP.md) | 目標と進捗 |
| [キーマップ設計](DESIGN.md) | ghostty / zellij / herdr / pi・omp のキー所有権と配色 |
| [Bookmarklets](assets/bookmarklets.md) | ブラウザタブのリスト化など bookmarklet 集 |

### 正本パス

| 関心事 | 正本 |
| --- | --- |
| macOS の Homebrew formula / cask / mas | `home/private_dot_config/Brewfile`（darwin bootstrap が `brew bundle` で適用） |
| Linux の OS パッケージ（apt）、macOS defaults | `home/private_dot_config/mise.toml` |
| CLI ツール、runtime | `home/private_dot_config/mise/conf.d/tools.toml` |
| skills、Windows の winget / scoop | `home/.chezmoidata/`（`agents.yaml` / `packages.yaml`） |
| VS Code 拡張 | `.devcontainer/devcontainer.json`（Dev Container）、`.vscode/extensions.json`（推奨） |
| 暗号化ファイル | Chezmoi の `encrypted_*` |
| 開発タスク | `Makefile`（root の `mise.toml` は `help` task の stub のみ。`.env` を読む `[env]` はコメントアウト中） |

### Platform rules

- `apt:*` → `{ os = "linux" }`（`mise.toml` の `[bootstrap.packages]` は apt のみ。macOS の brew / cask / mas は `Brewfile` が唯一の定義）
- 適用側も OS ごとに絞る（Linux は `mise bootstrap packages apply --manager apt`、macOS は `brew bundle --no-upgrade --file ~/.config/Brewfile`。mas は App Store へのサインインが必要）
- `bootstrap.services` / `bootstrap.compose` / `bootstrap.macos.launchd` は `mise.toml` でコメントアウト中
- Docker build（`DOCKER=true`）は `linux/setup.sh` を、Dev Container（`REMOTE_CONTAINERS=true`）は `vscode.sh` / `gui.sh` / `docker.sh` を `.chezmoiignore` で除外する


## GitHub Actions

- `test.yaml`: main push 後の install test
- `tag.yaml`: test 成功後の SemVer tag と release 作成
- `push.yaml`: Full、Slim、Dev image の amd64 / arm64 build と GHCR publish
- `ipfs.yaml`: main push ごとに repo 全体を mirror して IPFS に pin

## Chezmoi の基本操作

```sh
chezmoi init --apply budybye   # リモート初期化。`make init` の場合は不要
chezmoi cd
chezmoi diff
chezmoi apply
chezmoi update
```

設定変更後は、まず `make check` で差分を確認し、必要に応じて `make test` と `make verify` を実行します。
