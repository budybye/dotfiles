# ディレクトリ構成 - Chezmoi Dotfiles Management System

以下のディレクトリ構造に従って実装を行ってください：

```/
/
├── .cursor/                        # Cursor AI設定
│   └── rules/                      # AIルール定義
│       ├── global.mdc              # グローバルルール
│       ├── always-refer.mdc        # 常時参照ルール
│       ├── project-structure.mdc   # プロジェクト構造ルール
│       ├── package-management.mdc  # パッケージ管理ルール
│       └── development-guidelines.mdc # 開発ガイドライン
├── .devcontainer/                  # Dev Container設定
│   ├── docker-compose.yaml         # Docker Compose設定
│   ├── Dockerfile                  # Dockerイメージ定義
│   ├── devcontainer.json           # Dev Container設定
│   └── entrypoint.sh               # コンテナ起動スクリプト
├── .github/                        # GitHub設定
│   └── workflows/                  # GitHub Actions
│       ├── test.yaml               # テストワークフロー
│       ├── push.yaml               # プッシュワークフロー
│       └── tag.yaml                # タグワークフロー
├── .vscode/                        # VSCode設定
│   └── extensions.json             # 拡張機能設定
├── cloud-init/                     # クラウド初期化設定
│   ├── lxd.yaml                    # LXD設定
│   ├── multipass.yaml              # Multipass設定
│   ├── network-config              # ネットワーク設定
│   ├── template.cfg                # テンプレート設定
│   └── user-data                   # ユーザーデータ
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
│   ├── private_dot_config/         # 設定ファイル（XDG準拠）
│   │   ├── act/                    # GitHub Actions CLI
│   │   │   └── actrc
│   │   ├── alacritty/              # GPU加速ターミナル
│   │   │   └── alacritty.toml
│   │   ├── aquaproj-aqua/          # Aquaパッケージマネージャー
│   │   │   └── aqua.yaml
│   │   ├── bat/                    # シンタックスハイライト
│   │   │   └── config
│   │   ├── byobu/                  # ターミナルマルチプレクサー
│   │   │   ├── dot_byoburc
│   │   │   └── dot_tmux.conf
│   │   ├── chrome/                 # Chrome設定
│   │   │   └── extensions.json
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
│   │   ├── fish/                   # Fishシェル
│   │   │   └── config.fish
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
│   │   ├── homebrew/               # Homebrew設定
│   │   │   └── Brewfile
│   │   ├── ipfs/                   # IPFS設定
│   │   │   └── config
│   │   ├── karabiner/              # キーボードカスタマイズ
│   │   │   └── karabiner.json
│   │   ├── lsd/                    # モダンls
│   │   │   ├── colors.yaml
│   │   │   ├── config.yaml
│   │   │   └── icons.yaml
│   │   ├── mise/                   # ランタイム管理
│   │   │   └── config.toml
│   │   ├── mpd/                    # 音楽プレーヤーデーモン
│   │   │   └── mpd.conf.tmpl
│   │   ├── ncmpcpp/                # MPDクライアント
│   │   │   └── config
│   │   ├── neofetch/               # システム情報表示
│   │   │   └── config.conf
│   │   ├── npm/                    # npm設定
│   │   │   └── npmrc
│   │   ├── nvim/                   # Neovim設定
│   │   │   ├── colors/
│   │   │   │   └── monokai.vim
│   │   │   └── init.vim
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
│   │   │   └── tmux.conf
│   │   ├── uv/                     # Pythonパッケージ管理
│   │   │   └── uv.toml
│   │   ├── vim/                    # Vim設定
│   │   │   └── vimrc
│   │   ├── wireshark/              # ネットワーク解析
│   │   │   └── language
│   │   └── zsh/                    # Zsh設定
│   │       ├── dot_aliases
│   │       ├── dot_zlogin
│   │       ├── dot_zlogout
│   │       ├── dot_zprofile
│   │       └── dot_zshrc
│   ├── .chezmoi.toml.tmpl          # Chezmoiメイン設定
│   ├── .chezmoiexternal.toml.tmpl  # 外部リソース管理
│   ├── .chezmoiignore              # 除外ファイル設定
│   ├── dot_bash_profile            # Bashプロファイル
│   ├── dot_bashrc                  # Bash設定
│   ├── dot_profile                 # シェルプロファイル
│   ├── dot_zshenv                  # Zsh環境変数
│   ├── key.txt.age                 # 暗号化キーファイル
│   └── shhh.txt                    # シークレットファイル
├── .chezmoiroot                    # Chezmoiルート設定
├── .editorconfig                   # エディタ設定
├── .gitignore                      # Git除外設定
├── .tool-versions                  # バージョン管理
├── install.sh                      # 初期インストールスクリプト
├── Makefile                        # ビルド・管理スクリプト
├── README.md                       # プロジェクト説明
├── style.css                       # スタイルシート
├── technologystack.md              # 技術スタック定義
└── directorystructure.md           # ディレクトリ構成定義
```

## 配置ルール

### 設定ファイル管理

- **XDG 準拠設定**: `home/private_dot_config/` に配置
- **シェルスクリプト**: `home/.chezmoiscripts/` に配置
- **暗号化ファイル**: `*.age` 拡張子で暗号化
- **テンプレートファイル**: `*.tmpl` 拡張子で管理

### Chezmoi 管理

- **メイン設定**: `home/.chezmoi.toml.tmpl`
- **外部リソース**: `home/.chezmoiexternal.toml.tmpl`
- **除外設定**: `home/.chezmoiignore`
- **データ設定**: `home/.chezmoidata/`

### 環境別設定

- **OS 別スクリプト**: `home/.chezmoiscripts/darwin/`, `linux/`
- **環境変数**: テンプレート変数で制御
- **シークレット管理**: Bitwarden/1Password CLI 経由

### セキュリティ

- **SSH 鍵**: `home/dot_ssh/` で暗号化管理
- **暗号化ファイル**: `age` で暗号化
- **シークレット**: パスワードマネージャー経由でのみアクセス
- **OS 別分岐**: テンプレート変数による環境別設定
