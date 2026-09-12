---
name: directory
description: directory ファイル情報説明
---

# ディレクトリ構成 - Chezmoi Dotfiles Management System

以下のディレクトリ構造に従って実装を行ってください：

```/
/
├── .devcontainer/                  # Dev Container設定
│   ├── compose.yaml                # Docker Compose設定
│   ├── Dockerfile                  # Dockerイメージ定義
│   ├── devcontainer.json           # Dev Container設定
│   └── entrypoint.sh               # コンテナ起動スクリプト
├── .github/                        # GitHub設定
│   └── workflows/                  # GitHub Actions（流れは docs/tech.md「GitHub Actions パイプライン」）
│       ├── ipfs.yaml               # main push → IPFS ピン
│       ├── push.yaml               # semver タグ push → GHCR（latest はここだけ）
│       ├── tag.yaml                # test 成功後 → semver タグ + Release
│       └── test.yaml               # main push → インストール検証（docs/*.md は paths-ignore）
├── .vscode/                        # VSCode設定
│   └── extensions.json             # 拡張機能設定
├── cloud-init/                     # クラウド初期化設定
│   ├── lxd.yaml                    # LXD設定
│   ├── multipass.yaml              # Multipass設定
│   ├── network-config              # ネットワーク設定
│   ├── orbstack.yaml               # OrbStack設定
│   ├── template.cfg                # テンプレート設定
│   └── user-data                   # ユーザーデータ
├── docs/                           # ドキュメント
│   ├── requirements.md             # 要件定義・ゴール
│   ├── architecture.md             # 詳細設計・アーキテクチャ
│   ├── test.md                     # 検証設計・テストガイド
│   ├── tech.md                     # 技術スタック・正本
│   ├── directory.md                # ディレクトリ構成・命名規則
│   ├── security.md                 # セキュリティ・秘密情報
│   ├── problems.md                 # 環境差分・注意点
│   └── references.md               # 外部資料・参照リンク
├── ROADMAP.md                      # 目標・進捗
├── home/                           # ホームディレクトリ設定
│   ├── .chezmoidata/               # Chezmoiデータ
│   │   └── packages.yaml           # パッケージ設定
│   ├── .chezmoiscripts/            # Chezmoiスクリプト
│   │   ├── darwin/                 # macOS用スクリプト
│   │   ├── linux/                  # Linux用スクリプト
│   │   └── run_*.sh.tmpl           # 実行スクリプトテンプレート
│   ├── dot_ssh/                    # SSH設定
│   │   ├── authorized_keys.tmpl    # 認証キーテンプレート
│   │   ├── config.tmpl             # SSH設定テンプレート
│   │   ├── encrypted_private_id_ed25519.age # 暗号化秘密鍵
│   │   ├── encrypted_private_id_rsa.age     # 暗号化秘密鍵
│   │   └── id_ed25519.pub.tmpl    # 公開鍵テンプレート
│   ├── dot_local/                  # ユーザー実行ファイル（XDG準拠）
│   │   └── bin/
│   │       ├── executable_applist   # アプリ一覧出力
│   │       ├── executable_dump_zsh_state
│   │       ├── encrypted_private_executable_envars.age # 環境変数スクリプト（age暗号化）
│   │       ├── executable_jjj     # jj コミット・プッシュ
│   │       ├── executable_playlist # プレイリスト JSON / 音声取得
│   │       ├── executable_ssh_setup # SSH セットアップ（明示実行）
│   │       ├── executable_vibes   # 音楽関連
│   │       └── executable_xrp     # XRP 関連
│   ├── private_dot_config/         # 設定ファイル（XDG準拠）
│   │   ├── act/                    # GitHub Actions CLI
│   │   │   └── actrc
│   │   ├── aionui/                  # Aion UI設定
│   │   │   └── aionui-config.txt
│   │   ├── alacritty/              # GPU加速ターミナル
│   │   │   └── alacritty.toml
│   │   ├── aquaproj-aqua/          # Aquaパッケージマネージャー
│   │   │   └── aqua.yaml
│   │   ├── bat/                    # シンタックスハイライト
│   │   │   └── config
│   │   ├── byobu/                  # ターミナルマルチプレクサー
│   │   │   ├── datetime.tmux
│   │   │   ├── dot_byoburc
│   │   │   ├── dot_tmux.conf
│   │   │   ├── status
│   │   │   └── statusrc
│   │   ├── chrome/                 # Chrome設定
│   │   │   └── extensions.json
│   ├── dot_claude/                 # Claude AI設定（chezmoi適用時は ~/.claude）
│   │   ├── CLAUDE.md
│   │   └── settings.json.tmpl
│   │   ├── Code/                   # VSCode設定
│   │   │   └── user-data/
│   │   │       └── User/
│   │   │           ├── keybindings.json
│   │   │           └── settings.json
│   │   ├── element/                # Matrixクライアント
│   │   │   └── config.json
│   │   ├── fastfetch/              # システム情報表示
│   │   │   └── config.jsonc
│   │   ├── fcitx5/                 # 入力メソッド
│   │   │   └── config
│   │   ├── fusuma/                 # タッチパッドジェスチャー
│   │   │   └── config.yml
│   │   ├── gh/                     # GitHub CLI
│   │   │   ├── config.yml
│   │   │   └── hosts.yml
│   │   ├── ghostty/                # モダンターミナル
│   │   │   └── config
│   │   ├── git/                    # Git設定
│   │   │   ├── commit.template
│   │   │   ├── config
│   │   │   ├── ignore
│   │   │   └── user.conf.tmpl
│   │   ├── glow/                   # Markdown プレビュー
│   │   │   └── glow.yml
│   │   ├── htop/                   # プロセスモニタ
│   │   │   └── htoprc
│   │   ├── jj/                     # Jujutsu VCS
│   │   │   └── config.toml.tmpl
│   │   ├── karabiner/              # キーボードカスタマイズ
│   │   │   └── karabiner.json
│   │   ├── lsd/                    # モダンls
│   │   │   ├── colors.yaml
│   │   │   ├── config.yaml
│   │   │   └── icons.yaml
│   │   ├── mise/                   # ランタイム管理（60+ ツール、README 参考文献に一覧）
│   │   │   └── config.toml
│   │   ├── mpd/                    # 音楽プレーヤーデーモン
│   │   │   └── mpd.conf.tmpl
│   │   ├── ncmpcpp/                # MPDクライアント
│   │   │   └── config
│   │   ├── navi/                   # コマンドチートシート
│   │   │   └── config.yaml
│   │   ├── npm/                    # npm設定
│   │   │   └── npmrc
│   │   ├── nvim/                   # Neovim設定
│   │   │   ├── colors/
│   │   │   │   └── monokai.vim
│   │   │   ├── init.vim
│   │   │   └── lua/
│   │   │       └── gal.lua
│   │   ├── ripgrep/                # 高速検索
│   │   │   └── config
│   │   ├── sampler/                # システムモニタリング
│   │   │   └── config.yaml
│   │   ├── sheldon/                # シェルプラグイン管理
│   │   │   └── plugins.toml
│   │   ├── starship/               # シェルプロンプト
│   │   │   └── starship.toml
│   │   ├── tabby/                  # AIコード補完
│   │   │   └── config.yaml
│   │   ├── tldr/                   # コマンドヘルプ
│   │   │   └── config.toml
│   │   ├── tmux/                   # ターミナルマルチプレクサー
│   │   │   ├── dot_tmuxrc
│   │   │   └── tmux.conf
│   │   ├── uv/                     # Pythonパッケージ管理
│   │   │   └── uv.toml
│   │   ├── vim/                    # Vim設定
│   │   │   └── vimrc
│   │   ├── zed/                    # Zed エディタ
│   │   │   └── settings.json
│   │   ├── zellij/                 # ターミナルマルチプレクサー
│   │   │   ├── config.kdl
│   │   │   └── layouts/
│   │   │       └── dev.kdl
│   │   └── zsh/                    # Zsh設定
│   │       ├── dot_aliases
│   │       ├── dot_zlogin
│   │       ├── dot_zlogout
│   │       ├── dot_zprofile
│   │       └── dot_zshrc
│   ├── .chezmoi.toml.tmpl          # Chezmoiメイン設定
│   ├── .chezmoiexternal.toml       # 外部リソース管理
│   ├── .chezmoiignore              # 除外ファイル設定
│   ├── dot_bash_profile            # Bashプロファイル
│   ├── dot_bashrc                  # Bash設定
│   ├── dot_profile                 # シェルプロファイル
│   ├── dot_zshenv                  # Zsh環境変数
├── .chezmoiroot                    # Chezmoiルート設定
├── .editorconfig                   # エディタ設定
├── .gitignore                      # Git除外設定
├── .tool-versions                  # バージョン管理
├── install.sh                      # 初期インストールスクリプト
├── Makefile                        # ビルド・管理スクリプト
├── AGENTS.md                       # AI向けの説明(必要最低限)
├── README.md                       # プロジェクト説明(インストール方法、重要なファイル等)
└── style.css                       # スタイルシート
```

## 配置ルール

### 設定ファイル管理

- **XDG 準拠設定**: `home/private_dot_config/` に配置
- **シェルスクリプト**: `home/.chezmoiscripts/` に配置
- **実行可能スクリプト**: `home/dot_local/bin/` に配置。`executable_` プレフィックスで適用時に chmod +x を付与
- **Homebrew**: パッケージ一覧は `home/.chezmoidata/packages.yaml` で管理（Brewfile 前提の記述は使用しない）
- **暗号化ファイル**: `*.age` 拡張子で暗号化
- **テンプレートファイル**: `*.tmpl` 拡張子で管理

### Chezmoi 管理

- **外部リソース**: `home/.chezmoiexternal.toml`
- **除外設定**: `home/.chezmoiignore`
- **データ設定**: `home/.chezmoidata/`

### 環境別設定

- **OS 別スクリプト**: `home/.chezmoiscripts/darwin/`, `linux/`
- **環境変数**: テンプレート変数で制御
- **シークレット管理**: Chezmoi は age passphrase/symmetric、Mise runtime は `~/.config/mise/age.txt`

### セキュリティ

- **SSH 鍵**: `home/dot_ssh/` で暗号化管理
- **暗号化ファイル**: `age` で暗号化
- **シークレット**: パスワードマネージャー経由でのみアクセス
- **OS 別分岐**: テンプレート変数による環境別設定

## Chezmoi 設計とワークフロー

このプロジェクトは、[twpayne/dotfiles](https://github.com/twpayne/dotfiles)と chezmoi のベストプラクティスに基づいて構築されています。

### コアディレクトリ

- `home/`: ホームディレクトリ設定ファイル（chezmoi ソース状態）
- `.chezmoiroot`: Chezmoi ルートディレクトリマーカー（`home`を指す）
- `.tool-versions`: mise/asdf 互換バージョン管理ファイル

### Chezmoi 設定ファイル

- `.chezmoiexternal.toml`: 外部ファイルとアーカイブ管理
- `.chezmoiignore`: chezmoi で無視するファイル
- `.chezmoidata/`: テンプレート変数データ

### ファイル属性プレフィックス

Chezmoi はファイル名にメタデータを埋め込んで適切な属性を自動的に適用します：

- `dot_*`: dotfiles になる（例：`dot_zshrc` → `.zshrc`）
- `private_*`: 制限されたパーミッション用（0600）
- `encrypted_*`: age 暗号化用
- `executable_*`: 実行可能スクリプト用
- `symlink_*`: シンボリックリンク用
- `readonly_*`: 読み取り専用用（0444）

### スクリプト設計

#### スクリプト実行規則

Chezmoi スクリプトは `.chezmoiscripts/` ディレクトリ内に配置することで、`chezmoi apply` 時に自動的に実行されます。

#### スクリプト命名規則

- `.tmpl`: `chezmoi apply` でテンプレートとして認識されます
- `run_*`: `chezmoi apply` 中に名前順で実行されます
- `run_once_*`: `chezmoi apply` 時に一度だけ実行されます
- `run_onchange_*`: 前回の `chezmoi apply` から変更があった場合に実行されます
- `run_before_*`: ファイルインストール前に実行されます
- `run_after_*`: ファイルインストール後に実行されます

各スクリプト名から `after_`、`before_`、`onchange_`、`once_`、`run_`、`.tmpl` などの chezmoi 構文を除いた名前が実際のスクリプト名になります。

### スクリプト一覧と OS 対応

| Chezmoi Script                         | macOS | Ubuntu | WSL | PowerShell |
| -------------------------------------- | :---: | :----: | :-: | :--------: |
| run_once_before_active.sh              |  ✅   |   ✅   |     |            |
| run_once_before_age.sh.tmpl        |  ✅   |   ✅   |     |            |
| run_onchange_after_skills.sh.tmpl      |  ✅   |   ✅   |     |            |
| run_onchange_after_vscode.sh        |  ✅   |   ✅   |     |            |
| darwin/run_onchange_after_bootstrap.sh.tmpl |  ✅   |        |     |            |
| linux/run_once_after_docker.sh         |       |   ✅   |     |            |
| linux/run_onchange_after_cli.sh.tmpl   |       |   ✅   |     |            |
| linux/run_onchange_after_gui.sh.tmpl   |       |   ✅   |     |            |
| linux/run_once_after_setup.sh          |       |   ✅   |     |            |
| linux/run_onchange_after_snap.sh.tmpl  |       |   ✅   |     |            |
| windows/run_once_after_install.ps1.tmpl|       |        |     |     ✅     |

### Chezmoiignore 設計

`home/.chezmoiignore` で `chezmoi apply` 時に除外するファイルを管理できます。除外されたファイルは `chezmoi ignored` コマンドで確認できます。

#### 除外設定例

```txt
# template構文を使用できます

{{ if ne .chezmoi.os "linux" }}
.config/fcitx5
.config/fusuma

[Showing lines 1-300 of 539. Use :301 to continue]