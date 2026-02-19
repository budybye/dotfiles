---
name: directory
description: directory ファイル情報説明
---
# ディレクトリ構成 - Chezmoi Dotfiles Management System

以下のディレクトリ構造に従って実装を行ってください：

```/
/
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
├── docs/                           # ドキュメント
│   ├── plans/                      # 実装計画（YYYY-MM-DD-<feature>.md）
│   │   ├── TEMPLATE.md              # 計画ひな型
│   │   └── *.md                     # 日付付き実装計画
│   ├── plan.md                     # 計画書・索引・実行ガイド
│   ├── problems.md                 # 環境差の注意点・プラットフォーム差・ライブラリの癖
│   ├── requirements.md             # 要件定義書
│   ├── design.md                   # 詳細設計書（XDG仕様含む）
│   ├── tasks.md                    # タスク管理と実行計画書(AI管理、更新)
│   ├── tech.md                     # 技術スタック・実装詳細・ワークフロー（Chezmoi、パッケージ管理含む）
│   └── directory.md                # ディレクトリ構成設計
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
├── AGENTS.md                       # AI向けの説明(必要最低限)
├── README.md                       # プロジェクト説明(インストール方法、重要なファイル等)
└── style.css                       # スタイルシート
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

## Chezmoi 設計とワークフロー

このプロジェクトは、[twpayne/dotfiles](https://github.com/twpayne/dotfiles)と chezmoi のベストプラクティスに基づいて構築されています。

### コアディレクトリ

- `home/`: ホームディレクトリ設定ファイル（chezmoi ソース状態）
- `.chezmoiroot`: Chezmoi ルートディレクトリマーカー（`home`を指す）
- `.tool-versions`: mise/asdf 互換バージョン管理ファイル

### Chezmoi 設定ファイル

- `.chezmoi.toml.tmpl`: メイン chezmoi 設定テンプレート
- `.chezmoiexternal.toml.tmpl`: 外部ファイルとアーカイブ管理
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

| Chezmoi Script                       | macOS | Ubuntu | WSL | PowerShell |
| ------------------------------------ | :---: | :----: | :-: | :--------: |
| run_once_before_age.sh.tmpl          |  ✅   |   ✅   |     |            |
| run_once_before_bw.sh.tmpl           |  ✅   |   ✅   |     |            |
| run_after_activate.sh.tmpl           |  ✅   |   ✅   |     |            |
| run_onchange_after_bootstrap.sh.tmpl |  ✅   |        |     |            |
| run_onchange_after_defaults.sh.tmpl  |  ✅   |        |     |            |
| run_onchange_after_cli.sh.tmpl       |       |   ✅   |     |            |
| run_once_after_docker.sh.tmpl        |       |   ✅   |     |            |
| run_onchange_after_gui.sh.tmpl       |       |   ✅   |     |            |
| run_once_after_setup.sh.tmpl         |       |   ✅   |     |            |
| run_onchange_after_snap.sh.tmpl      |       |   ✅   |     |            |
| run_once_after_ssh.sh.tmpl           |  ✅   |   ✅   |     |            |
| run_onchange_after_vscode.sh.tmpl    |  ✅   |   ✅   |     |            |
| run_onchange_after_with.sh.tmpl      |  ✅   |   ✅   |     |            |
| run_onchange_after_xrp.sh.tmpl       |  ✅   |   ✅   |     |            |
| run_once_after_youtube.sh.tmpl       |  ✅   |   ✅   |     |            |

### Chezmoiignore 設計

`home/.chezmoiignore` で `chezmoi apply` 時に除外するファイルを管理できます。除外されたファイルは `chezmoi ignored` コマンドで確認できます。

#### 除外設定例

```txt
# template構文を使用できます

{{ if ne .chezmoi.os "linux" }}
.config/fcitx5
.config/fusuma
.local/share/fonts
.local/share/icons
.local/share/themes
.chezmoiscripts/linux/**
{{ end }}

.chezmoiexternal.*
key.txt.age
shhh.txt
```

この設計により、OS 固有の設定ファイルを適切に除外し、クロスプラットフォーム対応を実現しています。

### 外部ファイル管理

`.chezmoiexternal.toml.tmpl`で外部リソースを管理します：

#### サポートされるタイプ

- `file`: 単一ファイルダウンロード
- `archive`: アーカイブを展開
- `archive-file`: アーカイブから特定ファイルを展開
- `git-repo`: Git リポジトリのクローン/更新

#### 設定例

```toml
[".vim/autoload/plug.vim"]
    type = "file"
    url = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    refreshPeriod = "168h"

[".oh-my-zsh"]
    type = "archive"
    url = "https://github.com/ohmyzsh/ohmyzsh/archive/master.tar.gz"
    exact = true
    stripComponents = 1
    refreshPeriod = "168h"

# GitHub releaseから最新のバイナリを取得
[".local/bin/age"]
    type = "archive-file"
    url = {{ gitHubLatestReleaseAssetURL "FiloSottile/age" (printf "age-*-%s-%s.tar.gz" .chezmoi.os .chezmoi.arch) | quote }}
    executable = true
    path = "age/age"
    refreshPeriod = "168h"
```

### テンプレート変数システム

#### 組み込み変数

- OS 固有設定: `{{ if eq .chezmoi.os "darwin" }}`
- アーキテクチャ設定: `{{ .chezmoi.arch }}`
- ユーザ情報: `{{ .chezmoi.username }}`
- ホスト情報: `{{ .chezmoi.hostname }}`

#### カスタムデータ

- `.chezmoidata/`ディレクトリ内の YAML/TOML/JSON ファイル
- `.chezmoi.toml.tmpl`の`[data]`セクション
- 環境変数: `{{ env "VAR_NAME" }}`

#### パスワードマネージャ統合

```go
{{ bitwarden "item" "name" }}
{{ onepassword "vault" "item" "field" }}
{{ keepassxc "database" "entry" "attribute" }}
```

#### Go テンプレート構文

- Go text/template を拡張した sprig 関数ライブラリを活用
- OS 固有設定に`{{ if eq .chezmoi.os "darwin" }}`パターンを使用
- 環境変数アクセスに`{{ env "VAR_NAME" }}`を使用
- `{{ bitwarden "item" "name" }}`等でパスワードマネージャ統合を活用

##### 条件付き設定

```go
# 環境ベースの設定
{{ if eq .chezmoi.hostname "work-laptop" }}
# 仕事固有設定
{{ else if eq .chezmoi.hostname "personal-desktop" }}
# 個人設定
{{ end }}

# 機能フラグ
{{ if .features.development }}
# 開発ツールとエイリアス
{{ end }}
```

##### マルチ環境サポート

```toml
# .chezmoi.toml.tmpl
[data]
    {{- if eq .chezmoi.hostname "work-laptop" }}
    profile = "work"
    git_email = {{ onepassword "Work" "git" "email" | quote }}
    {{- else }}
    profile = "personal"
    git_email = {{ bitwarden "personal" "git-email" | quote }}
    {{- end }}
```

### コマンドリファレンス

#### 日常操作

```sh
# 設定ファイルを編集（透明暗号化サポート付き）
chezmoi edit ~/.ssh/config

# 変更をプレビュー
chezmoi diff

# 変更を適用
chezmoi apply

# ソースディレクトリに移動
chezmoi cd

# 設定のヘルスチェック
chezmoi doctor
```

#### ファイル管理

```sh
# 新しい設定ファイルを追加
chezmoi add ~/.gitconfig

# テンプレートとして追加
chezmoi add --template ~/.ssh/config

# 暗号化ファイルとして追加
chezmoi add --encrypt ~/.ssh/private_key

# 実行可能ファイルとして追加
chezmoi add --executable ~/.local/bin/script
```

#### セキュリティと暗号化

##### Age 暗号化

```sh
# 新しい暗号化キーを生成（Makefile経由）
make age-keygen
# 詳細: [設計書 - Makefile 設計 - セキュリティコマンド](./design.md#セキュリティコマンド)

# chezmoiで機密ファイルを暗号化
chezmoi add --encrypt ~/.ssh/private_key

# パスフレーズ対称暗号化
age --armor --passphrase | age --decrypt --output key.txt
```

##### Bitwarden 統合

```sh
# シークレット管理のためのvaultをアンロック（Makefile経由）
make bw-unlock
# 詳細: [設計書 - Makefile 設計 - セキュリティコマンド](./design.md#セキュリティコマンド)

# chezmoi統合でセキュアなシークレット注入
{{ bitwarden "item" "name" }}
```

#### テストと検証

##### ローカルテスト

```sh
# 設定チェックを実行（Makefile経由）
make check
# 詳細: [設計書 - Makefile 設計 - 開発](./design.md#開発)

# 分離されたDocker環境でテスト（Makefile経由）
make docker-run
# 詳細: [設計書 - Makefile 設計 - Docker コマンド](./design.md#docker-コマンド)

# chezmoi設定を検証
chezmoi diff
chezmoi doctor
chezmoi verify
```

##### デバッグツール

```sh
# トラブルシューティングのための詳細出力
chezmoi apply --verbose

# 変更をプレビューするためのドライラン
chezmoi apply --dry-run

# テンプレート実行のデバッグ
chezmoi execute-template < template.tmpl

# 外部ファイルソースを検証
chezmoi managed
```

#### ヘルスモニタリング

```sh
# 総合的なシステム情報（Makefile経由）
make system-info

# リソース一覧（Makefile経由）
make list-containers
make list-vms
# 詳細: [設計書 - Makefile 設計 - 情報コマンド](./design.md#情報コマンド)

# Chezmoi固有のヘルスチェック
chezmoi doctor
chezmoi verify
chezmoi unmanaged
```

### Chezmoi リファレンスドキュメント

#### 優先ドキュメント

1. [Chezmoi 公式ユーザーガイド](https://chezmoi.io/user-guide/command-overview/) - コマンド概要とワークフロー
2. [Chezmoi テンプレート機能](https://chezmoi.io/user-guide/templating/) - テンプレート構文とベストプラクティス
3. [Chezmoi 外部ファイル管理](https://chezmoi.io/user-guide/include-files-from-elsewhere/) - 外部リソース統合
4. [Chezmoi パスワードマネージャ統合](https://chezmoi.io/user-guide/password-managers/) - シークレット管理
5. [Chezmoi 暗号化](https://chezmoi.io/user-guide/encryption/) - Age/GPG 暗号化
6. [Chezmoi リファレンス](https://chezmoi.io/reference/) - 完全な API リファレンス

#### ベストプラクティスリファレンス

- [Tom Payne の dotfiles](https://github.com/twpayne/dotfiles) - Chezmoi 作成者によるリファレンス実装
- [Chezmoi 設計哲学](https://chezmoi.io/user-guide/frequently-asked-questions/design/) - 設計哲学と制約

## 関連ドキュメント

- [要件定義](./requirements.md) - 対応 OS・ツール要件
- [設計書](./design.md) - Makefile 設計
- [タスク管理](./tasks.md)
- [技術スタック](./tech.md) - パッケージ管理
