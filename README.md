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

`make init` は `install.sh` を実行します。checkout が `~/dotfiles` 以外にある場合だけ、`~/dotfiles` をその checkout への symlink として作ります（上の例のように `~/dotfiles` に clone した場合は symlink を作りません。`~/dotfiles` が既にあって別の場所を指していれば異常終了します）。そのうえで `~/dotfiles` を Chezmoi の source directory として登録します。実体の source tree は `.chezmoiroot` により `home/` です。リモートから初期化した場合の source directory は `~/.local/share/chezmoi` になります。

配置は `mode = "symlink"` です。テンプレート、暗号化ファイル、`executable_*` のファイル（`~/.local/bin/jjj` や `~/.local/bin/xrp` など）は symlink にならず実体のコピーになります。それ以外は repo の `home/` 配下への symlink になるため、適用先のファイルを編集（またはアプリが書き換え）すると repo の作業ツリーを直接変更します。コピーになるファイルを編集しても repo は変わらないので、source 側を編集して `chezmoi apply` してください。

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

公開済み image の pull だけを行う場合は `make docker-pull` または `make docker-slim-pull` を使います。`docker-ghcr-run` は `ubuntu-dev-ghcr` という別 container 名で起動するので、container 名は `make up`（Compose）や `make docker-run`（どちらも `ubuntu-dev`）と衝突しません。ただし host 側の `127.0.0.1:33389` は `make up`（既定。`RDP_PORT` で変更可）、`make docker-run`、`make docker-ghcr-run` が共通で使うため、この 3 つは既定のままでは同時に起動できません。`make exec` / `make logs` は `ubuntu-dev` を対象にします。

Compose の RDP port は localhost に bind します（SSH port の行はコメントアウト中）。remote access が必要な場合は VPN または Zero Trust tunnel を使います。

### Docker build の GitHub token

Docker build は dotfiles を clone して `make init` を実行します。clone 元は作業コピーではなく GitHub 上の `DOTFILES_REF`（既定 `main`）で、未 push の変更は image に入りません。Mise が GitHub の tool metadata を取得するため、local build では `GITHUB_TOKEN` を設定してください。

```sh
# GitHub CLI の認証済み token を一時的に渡す
GITHUB_TOKEN="$(gh auth token)" make docker-build
GITHUB_TOKEN="$(gh auth token)" make docker-slim-build
GITHUB_TOKEN="$(gh auth token)" make up
```

GitHub Actions では workflow の `secrets.GITHUB_TOKEN` を BuildKit secret として渡します。token を `.env`、Dockerfile の `ARG` / `ENV`、image layer に保存しないでください。`.env` と `.devcontainer/.env` は `.gitignore` 済み（追跡されるのは `.env.example` のみ）ですが、平文のため使いません。ルートの `mise.toml` の `[env] _.file = '.env'` はコメントアウトしてありますが、グローバルの `env_file = '.env'`（`mise/conf.d/settings.toml`）が cwd と全ての親ディレクトリの `.env` を、trust 確認も変数の絞り込みも無しで読み込みます。環境変数 `GITHUB_TOKEN` を要求するのは `make docker-build` / `docker-slim-build`（これらに依存する `docker-run` を含む）で、未設定だと失敗します。`docker-pull` / `docker-slim-pull` / `docker-ghcr-run` は要求しません。

### GitHub token の差し替え

現状は、スコープなしの classic PAT が次の 4 か所に同じ値で入っています。差し替えるときは全てそろえ、確認してから旧 token を revoke します。

| 場所 | 変数 | 差し替え方 |
| --- | --- | --- |
| repo 直下の `.env` と `.devcontainer/.env` | `GITHUB_TOKEN` | 行を置換する（`.devcontainer/.env` の `MISE_GITHUB_TOKEN` は `${GITHUB_TOKEN}` を参照するだけ） |
| `~/.env`（`home/encrypted_private_dot_env.age` から展開） | `MISE_GITHUB_TOKEN` | `chezmoi edit --apply ~/.env`。暗号文が変わるので commit して push する |
| GitHub Actions の repo secret | `MISE_GITHUB_TOKEN` | `gh secret set` |
| 実行中の shell | `GITHUB_TOKEN` / `MISE_GITHUB_TOKEN` | `export`（`gh` は環境変数を keyring より優先するので、更新しないと revoke 後に 401 になる） |

```sh
# 1. 新しい token を作る: fine-grained PAT、Public repositories (read-only)、権限なし、期限あり
#    https://github.com/settings/personal-access-tokens/new
# 2. 画面にも履歴にも残さず読み込む (zsh)
read -s "NEW?new token: "
# 3. 差し替える
sed -i '' "s|^GITHUB_TOKEN=.*|GITHUB_TOKEN=\"$NEW\"|" .env .devcontainer/.env
chezmoi edit --apply ~/.env   # MISE_GITHUB_TOKEN の行を新しい値にして保存する。age の passphrase が要る
GH_TOKEN="$(env -u GITHUB_TOKEN gh auth token --user budybye)" \
  gh secret set MISE_GITHUB_TOKEN --repo budybye/dotfiles --body "$NEW"
export GITHUB_TOKEN="$NEW" MISE_GITHUB_TOKEN="$NEW"
# 4. 確認する
gh api /user --jq .login
# 5. 確認後に旧 token を revoke する: https://github.com/settings/tokens
```

PAT は API から消せないため、revoke は GitHub の画面で行います。

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
| [キーマップ設計](DESIGN.md) | ghostty / herdr / pi・omp のキー所有権と配色（zellij は不採用で、herdr が無い環境のフォールバック起動のみ） |
| [Bookmarklets](assets/bookmarklets.md) | ブラウザタブのリスト化など bookmarklet 集 |

### 正本パス

| 関心事 | 正本 |
| --- | --- |
| macOS の Homebrew formula / cask | `home/private_dot_config/mise.toml` の `[bootstrap.packages]`（bootstrap が `brew:` / `brew-cask:` を適用。`mas:` は適用しない）。`home/private_dot_config/Brewfile` は `bb` / `bf` / `bcf` だけが読む別の一覧で、内容は一致しない（`bcf` は Brewfile に無いものを削除する） |
| Linux の OS パッケージ（apt）、macOS defaults | `home/private_dot_config/mise.toml` |
| CLI ツール、runtime | `home/private_dot_config/mise/conf.d/tools.toml` |
| skills、Windows の winget / scoop | `home/.chezmoidata/`（`agents.yaml` / `packages.yaml`） |
| VS Code 拡張 | `.devcontainer/devcontainer.json`（Dev Container）、`.vscode/extensions.json`（推奨） |
| 暗号化ファイル | Chezmoi の `encrypted_*` |
| 開発タスク | `Makefile`（root の `mise.toml` は `help` task の stub のみ。`.env` を読む `[env]` はコメントアウト中） |

### Platform rules

- `apt:*` → `{ os = "linux" }`、`brew:*` / `brew-cask:*` → `{ os = "macos" }` または `"latest"`（`mise.toml` の実際の形式に従う。`mas:*` は適用しないので無効）
- 適用側も OS ごとに絞る（Linux は `mise bootstrap packages apply --manager apt`、macOS は `--manager brew` / `--manager brew-cask`。`brew bundle` と `--manager mas` は、CI の macOS runner が App Store に sign in できず止まるためコメントアウト中）
- `bootstrap.services` / `bootstrap.compose` / `bootstrap.macos.launchd` は `mise.toml` でコメントアウト中
- Docker build（`DOCKER=true`）は `linux/setup.sh` を、`REMOTE_CONTAINERS=true` は `vscode.sh` / `gui.sh` / `docker.sh` を `.chezmoiignore` で除外する。`REMOTE_CONTAINERS=true` は Dev Container（`devcontainer.json` の `remoteEnv`）だけでなく Slim image も `slim.Dockerfile` の `ENV` で設定する（Slim は `DOCKER=true` も設定するので 4 つとも除外され、profile 名も `dev` になる）。Full image は `DOCKER=true` のみ


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
