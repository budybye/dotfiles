---
name: tech
description: 技術スタック パッケージ管理 ライブラリ説明
---
# 技術スタック - Chezmoi Dotfiles Management System

## ドキュメント方針

- このファイルは「実際に使っている技術と管理元」を記載する
- 詳細な手順と文書索引は `../README.md`、参照リンク集は `references.md` に集約する
- `references.md` のタグ（`active` / `optional` / `legacy`）は参照の温度感を示す補助情報で、採用判断の正本は本ファイルと設定ファイルに置く
- source of truth は次の6つ
  - `home/private_dot_config/mise/conf.d/tools.toml`（ツール定義）
  - `home/private_dot_config/mise/conf.d/settings.toml`（mise 設定）
  - `home/private_dot_config/mise.toml`（`mise bootstrap`: macOS defaults と、`apt:`（Linux）/ `brew:` / `brew-cask:`（macOS）パッケージ。bootstrap が入れる一覧。`mas:` の行は持つが適用しない）
  - `home/private_dot_config/Brewfile`（macOS の Homebrew 一覧。bootstrap は適用せず、`bb` / `bf` / `bcf` エイリアスだけが読む。`mise.toml` と重複する別の一覧で、内容は一致しない）
  - `home/.chezmoidata/packages.yaml`（Windows の winget / scoop。`curl:` リストは参照するテンプレートが無く未使用）
  - `home/private_dot_config/aquaproj-aqua/aqua.yaml`

## コア技術

- **Chezmoi**: dotfiles 管理の中核
- **Mise**: 言語ランタイムと CLI の統合管理
- **Homebrew / APT / Winget / Scoop**: OS ごとのパッケージ管理（macOS は `mise bootstrap packages`（brew / brew-cask）と、`bb` / `bcf` 用の `Brewfile`、Linux は `mise bootstrap`（apt）で、Windows は `packages.yaml`）
- **Aqua**: 宣言的な追加 CLI 管理
- **Cargo / npm / Go / Python**: 言語別 CLI 配布

## 対応 OS・プラットフォーム

- **macOS Sequoia**
- **Ubuntu 26.04 LTS** (Docker image・GitHub Actions runner で確認済み。`make init` を走らせるのは ubuntu amd64 / arm64 と macOS のジョブのみで、LXD / RPi ジョブは cloud-init の起動確認（`|| true`）まで。OrbStack は image ピン未指定)
- **Docker / Dev Container**
- **Windows（予定）**: Winget / Scoop の定義と `windows/run_once_after_install.ps1.tmpl` のみ。CI は checkout・scoop 準備まで

## パッケージ管理

### Mise（主軸）

- **ツール定義**: `home/private_dot_config/mise/conf.d/tools.toml`（有効 193 / コメントアウト 165（2026-11-01 時点）。実数は `mise ls`。コメントアウト行は再有効化用に残す。macOS で動かない `ttyd` / `fish-shell` は `os = ["linux"]` で Linux のみ）
- **設定**: `home/private_dot_config/mise/conf.d/settings.toml`。`config.toml` は shell alias と hooks のみ
- **運用**:
  - ほぼ全て `latest` 指定。`lockfile = true`（グローバル tool のロックは `mise lock --global` を実行したマシンにだけ `~/.config/mise/mise.lock` として作られ、リポジトリ管理外。`make init` は `mise i -y` のみなので、新規マシン・CI・Docker には lockfile が無く checksum は照合されない。`lockfile_platforms` は macOS arm64 のみ。検知できるのは lock を作ったマシンでの以降の差し替えのみ）
  - `minimum_release_age = "12h"`（公開から 12h 未満の版は採用しない。リリース日を返さない `http:` tool には効かない。`node` / `pi` / `oh-my-pi` / `lazyxrp` は除外）
  - `self_update.auto` と `tool_update.global_auto` で本体・グローバル tool を自動更新
  - グローバルの `env_file = '.env'` を設定している（意図的）。cwd と全ての親ディレクトリの `.env` を読み（近い方が勝つ。`mise.toml` は不要）、全ての `[env]` の後に適用して上書きする。trust 確認も変数の絞り込みも無く、`LD_PRELOAD` / `NODE_OPTIONS` 等も通るため、clone した未信頼 repo の `.env` も自動で export される。cwd が `$HOME` 配下なら `~/.env`（`home/encrypted_private_dot_env.age` から chezmoi が配置。age パスフレーズ暗号で公開 repo にあり、守るのはパスフレーズのみ）も読む。mise は dotenv を復号できない。トップレベルの `env_file` キーは deprecated（2027.4.0 で削除予定）だが `[settings]` の形式は対象外。`yes` は設定しない（未信頼の `mise.toml` を自動 trust してしまうため）。リポジトリ直下 `mise.toml` の `[env] _.file = '.env'` はコメントアウト中で何も足さない
  - `activate_aggressive = false`（毎プロンプトで tool の PATH を先頭へ戻さない。venv 等が足した PATH を潰さないため）
  - 慣習的バージョンファイル（`.nvmrc` 等）は node / python / ruby / go のみ有効。`legacy_version_file` / `asdf_compat` は廃止済みで使わない
  - バックエンド: `cargo.binstall = true`、`pypi.uvx = true`、`npm.package_manager = "bun"`
  - `http:` バックエンド: `http:coderabbit` / `http:cursor-cli`（公式 `install.sh` の代替）。coderabbit は `releases/latest/VERSION` で版を解決し `checksum_expr` で `SHA256SUMS` を照合、cursor-cli は `install.sh` 内の版を正規表現で取り、checksum 非公開のため lockfile 初回計算値で照合（初回は無検証）、同梱 `node` / `rg` を隠すため `postinstall` で `bin/` に `agent` / `cursor-agent` を作る。どちらも署名検証とリリース日（`minimum_release_age`）は効かない。対象は macOS / Linux（x64・arm64）で、Windows は `.chezmoiignore` が `.config/**` を配置しないため対象外。`make init` と devcontainer ビルドは 1 回あたり約 225 MB（cursor-cli 183 MB・coderabbit 41 MB）のダウンロードが増え、一過性の失敗で `mise i -y` が非 0 になっても `run_onchange_after_cli.sh.tmpl` は `|| echo` で続行し、残りのツールは入る（`mise install` の再実行で復旧）
  - Rust は `rust.cargo_home` / `rust.rustup_home` を XDG（`~/.local/share`）に固定
  - mise 本体の導入元は `run_once_before_age.sh.tmpl`・`darwin/run_onchange_after_bootstrap.sh.tmpl`・`linux/run_onchange_after_cli.sh.tmpl`（`install.sh` は mise を入れない）

### mise bootstrap（macOS / Linux パッケージ）

- **設定**: `home/private_dot_config/mise.toml`
- **役割**:
  - `[bootstrap.macos.*]`: キーボード・トラックパッド・Dock・Finder・`defaults` の設定
  - `[bootstrap.packages]`: `apt:`（Linux）、`brew:` / `brew-cask:`（macOS）、`mas:`（macOS。適用しないので無効）。`brew:` / `brew-cask:` は `{ os = "macos" }` または `"latest"`
- **適用**: `home/.chezmoiscripts/darwin/run_onchange_after_bootstrap.sh.tmpl` は `mise bootstrap packages apply --manager brew` / `--manager brew-cask` と `mise bootstrap macos defaults apply` を実行し、`linux/run_onchange_after_cli.sh.tmpl` は `mise bootstrap packages apply --manager apt` を実行する。`brew bundle` と `--manager mas` はコメントアウト中（`brew bundle` は Brewfile の `mas` アプリ（Logic Pro / RunCat / Shazam）も入れ、CI の macOS runner は App Store に sign in できず `mas` が止まって job が timeout-minutes 60 で cancel されたため）。darwin / linux とも `mise.toml` / `tools.toml` の sha256 を埋め込み、変更時に再実行される
- **Brewfile**: `home/private_dot_config/Brewfile`（macOS のみ配置）は `bb` / `bf` / `bcf` エイリアスだけが読む一覧で、bootstrap は適用しない。`mise.toml` とは別の一覧で、Brewfile だけにある cask（`blender` / `cloudflare-warp` / `github` / `onyx` / `raycast` / `windows-app` / `wireshark-app`）は bootstrap が入れず、`mise.toml` だけにある `mpd` / `mpc` / `ncmpcpp` / `orca` / `tradingview` は Brewfile に無い（コメントアウト）ため `bcf`（`brew bundle cleanup`）が削除する。一覧の一本化は未了（ROADMAP M2）

### packages.yaml（Windows）

- 設定: `home/.chezmoidata/packages.yaml`
- 役割:
  - `windows.winget`, `windows.scoop`（`windows/run_once_after_install.ps1.tmpl` が参照）
  - `curl:` に `curl | sh` の一覧（mise / fx / zed）があるが、どのテンプレート・スクリプトも参照しない
- スキル一覧は `agents.yaml`（`run_onchange_after_skills.sh.tmpl` が参照）。`extensions.yaml`（VSCode 拡張）はどこからも参照されず、`run_onchange_after_vscode.sh.tmpl` は拡張をインストールしない（Dev Container は `devcontainer.json`、推奨は `.vscode/extensions.json`）

### Aqua（補助）

- **設定ファイル**: `home/private_dot_config/aquaproj-aqua/aqua.yaml`
- **役割**: 宣言的な追加 CLI 配布管理
- **現在の定義**:
  - `b3nj5m1n/xdg-ninja@v0.2.0.2` (XDG Base Directory チェックツール)
- **特徴**:
  - checksum 検証は `aqua.yaml` 内でコメントアウトされており、現在は無効
  - 現在は少数のツールだが、将来の拡張を見込む

## 実際に利用している主要カテゴリ

### シェル・ターミナル

- **zsh**（デフォルト）
- **bash**（互換用）
- **starship**（プロンプト）
- **sheldon**（zsh プラグインマネージャー）
- **zellij**（ターミナルマルチプレクサ。herdr へ切替済み。`herdr-dev` が使えない環境のフォールバックとして `.zlogin` が起動する）
- **herdr**（ターミナルマルチプレクサ。現行。起動は `executable_herdr-dev`）
- **atuin**（シェル履歴）
- **zoxide**（スマート cd）
- **fzf**（ファジー検索）
- **bat**（cat 拡張）
- **fd**（find 拡張）
- **rg**（ripgrep）
- **lsd**（ls 拡張）
- **bottom**（システムモニタ）
- **ghostty / ratty**（ターミナルエミュレータ。ghostty は `mise.toml` / `Brewfile` の cask、ratty は `tools.toml`）
- **fish**（Linux のみ。`tools.toml` で `os = ["linux"]`）

### 開発・CI/CD

- **git / gh / ghq**
- **jj / jjui / jj-starship**（Jujutsu バージョン管理）
- **delta**（diff ビューア）
- **lazygit / lazydocker**（TUI）
- **docker / devcontainer-cli**
- **act**（GitHub Actions ローカル実行）
- **task**（Taskfile / make 代替。導入のみで `Taskfile.yml` は無く、実体は Makefile）
- **pre-commit**
- **pi / oh-my-pi（omp）**（コーディングエージェント。設定は `private_dot_config/pi/`・`omp/`）
- **lumen / octorus**（diff / PR レビュー TUI）
- **graphify**（コードベース知識グラフ。除外は `.graphifyignore`）
- **github actions（workflow）** — 下記「GitHub Actions パイプライン」

#### GitHub Actions パイプライン

`main` への push（`test.yaml` の `paths-ignore`: `docs/**`・`*.md`・`README.md`）で次の順に実行する。

1. **`test.yaml`** — ubuntu amd64 / arm64・macOS で `make init`。LXD / RPi は cloud-init 起動確認、Windows 系 3 ジョブは checkout（+ scoop）のみ
2. **`tag.yaml`** — 上記成功時のみ（`workflow_run`）。対象コミットに semver タグが無ければパッチ +1 の `X.Y.Z` を付与し GitHub Release を作成
3. **`push.yaml`** — semver タグの push 時、または `tag.yaml` 成功後の `workflow_dispatch` で GHCR に build & push（`0.8.123` / `0.8` / `latest`）

補足:

- **バージョンの単一ソース**は git の semver タグ。`make version` は `git describe` を表示する（`Makefile` の `DOTFILES_VERSION` はタグから導出）
- **`tag.yaml` はリリース作成後に `gh workflow run push.yaml --ref <tag>` を実行** — tag push イベントだけに依存しない
- **`push.yaml` は `main` 単独 push では走らない** — `latest` と Release 済みイメージのズレを防ぐ
- **`schedule`（毎日）** — プラットフォーム・flavor 別の GitHub Actions BuildKit キャッシュ更新のみ。`latest` / semver タグは付けない。concurrency は `scheduled-cache-refresh` で `workflow_dispatch`（main）と分離
- **`ipfs.yaml`** — `main` push で IPFS ピン（コンテナとは独立）
- 非 semver タグ（例: `push`）は `tag.yaml` の対象外。リモートに上げないこと
- **OrbStack smoke test** — GitHub-hosted macOS の nested virtualization 制約により、`test.yaml` の job は現在コメントアウト中。物理 macOS self-hosted runner 導入時に復帰する

### クラウド・インフラ

- **wrangler**（Cloudflare Workers）
- **cloudflared**（Cloudflare Tunnel）
- **caddy**（Web サーバー・リバースプロキシ）
- **cfssl**（証明書管理）
- **serverless**

### セキュリティ

- **age**（暗号化）
- **bitwarden**
- **ssh**
- **trivy**（コンテナ脆弱性スキャン）
- **mkcert**（ローカル証明書）
- **shellcheck**（シェルスクリプト静的解析）

### 主要開発言語・ランタイム

Mise で管理する主要な言語および関連ツール。

- **JavaScript/TypeScript**: node, bun, pnpm
- **Python**: python, uv（パッケージマネージャー）, pipx, ruff, hatch
- **Go**: go
- **Rust**: rust, cargo-binstall
- **Java**: java, maven

### その他のユーティリティ

- **データ・フォーマット**: jq, yq, fx, yamlfmt
- **ネットワーク**: xh, hurl, curl（システム）
- **ストレージ**: rclone, sqlite
- **ビルド**: ninja, conan
- **開発補助**: just, watchexec, ast-grep, hyperfine, lychee, hadolint, pandoc, ffmpeg, neovim, micro, yazi, cheat
- **その他**: dust, scooter, coreutils, fastfetch, checkmake, cowsay, topgrade, yt-dlp, termshark, wtf

## 注意事項

- 具体的な「どのツールが有効か」はコメントアウト状態も含め `mise/conf.d/tools.toml`、`Brewfile`（macOS の `bb` / `bcf`）、`mise.toml`（apt / brew / brew-cask / macOS defaults）を優先する
- README は概要のみを保持し、ツール一覧の重複列挙はしない
- バージョンの厳密な固定値が必要な場合は、個別ファイル（`tools.toml`, `aqua.yaml`）を更新する

## 関連ドキュメント

- [README](../README.md)
- [要件定義](./requirements.md)
- [アーキテクチャ](./architecture.md)
- [ディレクトリ構成](./directory.md)
- [環境差の注意点](./problems.md)
- [参考文献](./references.md)

## VCS / キーバインド / skill 運用

- jj をローカル操作の標準とし、Git は remote・CI・互換境界に残す。
- キーバインドは各アプリ設定と [DESIGN.md](../DESIGN.md)（キー所有権と配色の表）を正本とし、terminal → multiplexer → shell の順で競合を解消する。
- skill manager は一つを project owner にし、複数 manager に同名 skill を登録しない。認証情報は lock/report に保存しない。

VCS 運用で未了の項目は `ROADMAP.md` M8-4 の `make git-commit` 廃止のみ（M2 は Mise / Chezmoi 移行で VCS を含まない）。ツール・package の実値は Mise / Chezmoi data / Aqua の設定ファイルを参照する。
