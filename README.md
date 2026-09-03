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
# Full image を build
make docker-build

# Full image を起動
make docker-run

# Compose service を起動・停止
make up
make down

# 起動中の container に接続
make exec
make logs
```

Compose の RDP と SSH port は localhost に bind します。remote access が必要な場合は VPN または Zero Trust tunnel を使います。

### Docker build の GitHub token

Docker build は dotfiles を clone して `make init` を実行します。Mise が GitHub の tool metadata を取得するため、local build では `GITHUB_TOKEN` を設定してください。未設定でも build は開始しますが、GitHub API の rate limit で失敗する可能性があります。

```sh
# GitHub CLI の認証済み token を一時的に渡す
GITHUB_TOKEN="$(gh auth token)" make up
```
`make up` は Compose の BuildKit secret を使います。`make docker-build` は直接 `docker build` を実行して secret を渡さないため、token を使う local build では `make up` を使ってください。

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

## 対応プラットフォーム

- macOS Sequoia 15 以降
- Ubuntu 24.04 LTS
- Docker
- Multipass

WSL2、Windows、FreeBSD は将来対応です。対応範囲と package 要件は [要件定義](docs/requirements.md) を参照してください。

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
| [ドキュメント索引](docs/README.md) | ドキュメントと source of truth |
| [技術スタック](docs/tech.md) | ツールと package manager |
| [ディレクトリ構成](docs/directory.md) | Chezmoi の配置と運用 |
| [要件定義](docs/requirements.md) | OS と tool の要件 |
| [環境差の注意点](docs/problems.md) | platform 差分と troubleshooting |
| [設計書](docs/design.md) | 設計方針と Makefile |
| [セキュリティ](docs/security.md) | age、SSH、secret、CI |
| [参考文献](docs/references.md) | 公式 docs と repository |

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
