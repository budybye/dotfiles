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

`make init` は `install.sh` を実行し、`~/dotfiles` を Chezmoi の source directory として登録します。

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

`make check` は `chezmoi diff`、`make test` はテンプレート構文と dry-run、`make verify` は Chezmoi の検証を実行します。

## Docker

`.devcontainer/` には Full GUI image と Slim CLI image の Dockerfile があります。Full image は XFCE と xrdp、Slim image は SSH と CLI ツールを含みます。CI は `linux/amd64` と `linux/arm64` の image を GHCR に公開します。

```sh
# ローカルで build（GHCR と同じタグ形式で保存するだけ。push は CI）
make docker-build
make docker-slim-build

# 公開済み GHCR image を pull して起動（ローカル build とは別）
make docker-ghcr-run

# ローカル build 済みの Full image を起動
make docker-run

# Compose service を起動・停止
make up
make down

# 起動中の container に接続
make exec
make logs
```

公開済み image の pull だけを行う場合は `make docker-pull` または `make docker-slim-pull` を使います。`docker-ghcr-run` は `ubuntu-dev-ghcr` という別 container 名で起動します。

Compose の RDP と SSH port は localhost に bind します。remote access が必要な場合は VPN または Zero Trust tunnel を使います。

### Docker build の GitHub token

Docker build は dotfiles を clone して `make init` を実行します。Mise が GitHub の tool metadata を取得するため、local build では `GITHUB_TOKEN` を設定してください。

```sh
# GitHub CLI の認証済み token を一時的に渡す
GITHUB_TOKEN="$(gh auth token)" make docker-build
GITHUB_TOKEN="$(gh auth token)" make docker-slim-build
GITHUB_TOKEN="$(gh auth token)" make up
```

GitHub Actions では workflow の `secrets.GITHUB_TOKEN` を BuildKit secret として渡します。token を `.env`、Dockerfile の `ARG` / `ENV`、image layer に保存しないでください。

## Multipass

```sh
make vm-create
make vm-start
make ssh
make vm-info
make vm-stop
make clean-vm
```

## OrbStack

```sh
orb create ubuntu orb-dev -c cloud-init/orbstack.yaml
orb -m orb-dev
```

OrbStack用のcloud-initはCLI中心で、xrdpやデスクトップ環境を含めません。

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
- `.github/workflows/`: test、release、GHCR build workflow
- `docs/`: 設計、運用、セキュリティ、トラブルシューティング

## ドキュメント

| ドキュメント | 内容 |
| --- | --- |
| [要件定義](docs/requirements.md) | 目的、制約、対応範囲 |
| [アーキテクチャ](docs/architecture.md) | Chezmoi、Mise、bootstrap、レイヤー設計 |
| [検証ガイド](docs/test.md) | ローカル、CI、OS別の検証 |
| [技術スタック](docs/tech.md) | 技術選定と設定の正本 |
| [ディレクトリ構成](docs/directory.md) | Chezmoi の配置と命名規則 |
| [セキュリティ](docs/security.md) | age、SSH、secret、CI |
| [環境差の注意点](docs/problems.md) | platform 差分と troubleshooting |
| [参考文献](docs/references.md) | 公式 docs と repository |
| [ROADMAP](ROADMAP.md) | 目標と進捗 |

README、docs、ROADMAPだけでプロジェクトの運用情報を完結させます。詳細な変更計画を必要とする場合は、ローカルのOpenSpecをGit管理外で任意に利用できます。

### 正本パス

| 関心事 | 正本 |
| --- | --- |
| OS パッケージ、macOS defaults | `home/private_dot_config/mise.toml` |
| CLI ツール、runtime | `home/private_dot_config/mise/config.toml` |
| VS Code、skills、Chezmoi data | `home/.chezmoidata/packages.yaml` |
| 暗号化ファイル | Chezmoi の `encrypted_*` |
| 開発タスク | `.mise.toml` の `[tasks]` |

### Platform rules

- `brew:*`、`brew-cask:*`、`mas:*` → `os = "macos"`
- `apt:*` → `os = "linux"`
- `home/private_dot_config/mise/ci.toml` → Mac full packages / Linux CLI packages
- `home/private_dot_config/mise/docker.toml` → Linux CLI packages only
- `bootstrap.services` / `bootstrap.compose` → Ubuntu VM の systemd / Docker
- `bootstrap.macos.launchd` → macOS の LaunchAgent
- Docker container では system service bootstrap を実行しない


## GitHub Actions

- `test.yaml`: main push 後の install test
- `tag.yaml`: test 成功後の SemVer tag と release 作成
- `push.yaml`: Full、Slim、Dev image の amd64 / arm64 build と GHCR publish

## Chezmoi の基本操作

```sh
chezmoi init --apply budybye
chezmoi cd
chezmoi diff
chezmoi apply
chezmoi update
```

設定変更後は、まず `make check` で差分を確認し、必要に応じて `make test` と `make verify` を実行します。
