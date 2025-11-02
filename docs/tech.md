# 技術スタック - Chezmoi Dotfiles Management System

## コア技術

- **Chezmoi**: ^2.47.0 - ドットファイル管理システム
- **Go**: ^1.21.0 - Chezmoi の実行環境
- **Bash**: ^5.0.0 - シェルスクリプト実行環境
- **Zsh**: ^5.9.0 - ログインシェル環境
- **Make**: ^4.0.0 - ビルドツール

## 対応 OS・プラットフォーム

- **macOS**: Sequoia (14.0+) - プライマリ開発環境
- **Ubuntu**: 24.04 LTS (Noble Numbat) - Linux 開発環境
- **Docker**: ^24.0.0 - コンテナ化環境
- **Multipass**: ^1.13.0 - 軽量 VM 管理
- **WSL2**: Ubuntu 24.04 LTS - Windows Subsystem for Linux 2

## 開発ツール・エディタ

- **VSCode**: ^1.85.0 - メインエディタ
- **Cursor**: ^0.45.0 - AI 支援エディタ
- **Claude**: ^4 - Console AI Agents
- **Neovim**: ^0.9.0 - ターミナルエディタ
- **Alacritty**: ^0.13.0 - GPU 加速ターミナル
- **Ghostty**: ^0.3.0 - モダンターミナル
- **Byobu(tmux)** - ターミナルマルチプレクサ

## シェル・ターミナル

- **Zsh**: ^5.9.0 - メインシェル
- **Fish**: ^3.7.0 - 対話的シェル
- **Bash**: ^5.2.0 - 互換性シェル
- **Starship**: ^1.18.0 - シェルプロンプト
- **Sheldon**: ^0.7.0 - シェルプラグイン管理

## パッケージ管理ツール

- **Homebrew**: ^4.1.0 - macOS パッケージ管理
- **Mise**: ^0.2.0 - ランタイムバージョン管理
- **Aqua**: ^2.20.0 - パッケージマネージャー
- **UV**: ^0.2.0 - Python パッケージ管理

詳細は[パッケージ管理](#パッケージ管理)セクションを参照してください。

## セキュリティ・暗号化

- **Age**: ^1.1.0 - モダン暗号化ツール
- **Bitwarden CLI**: ^1.0.0 - パスワード管理
- **SSH**: ^9.0.0 - セキュアシェル

## 開発環境・CI/CD

- **Git**: ^2.40.0 - バージョン管理
- **GitHub Actions**: ^3.0.0 - CI/CD
- **Dev Containers**: ^1.0.0 - 開発コンテナ
- **Docker Compose**: ^2.20.0 - コンテナオーケストレーション

## システム管理・モニタリング

- **Fastfetch**: ^10.0.0 - システム情報表示
- **Neofetch**: ^7.1.0 - システム情報表示
- **Sampler**: ^1.1.0 - システムモニタリング
- **Byobu**: ^5.133.0 - ターミナルマルチプレクサー
- **Tmux**: ^3.3.0 - ターミナルマルチプレクサー

## ファイル管理・検索

- **Ripgrep**: ^13.0.0 - 高速検索
- **Bat**: ^0.24.0 - シンタックスハイライト
- **LSD**: ^0.24.0 - モダン ls
- **Fusuma**: ^2.0.0 - タッチパッドジェスチャー

## ネットワーク・通信

- **Wireshark**: ^4.0.0 - ネットワーク解析
- **IPFS**: ^0.20.0 - 分散ファイルシステム
- **Element**: ^1.11.0 - Matrix クライアント

## メディア・エンターテイメント

- **MPD**: ^0.23.0 - 音楽プレーヤーデーモン
- **NCMPCPP**: ^0.9.0 - MPD クライアント
- **ffmpeg**: ^6.0.0 - メディアフォーマット管理
- **yt-dl** - youtube ダウンローダー (使えなくなった)

## 入力・アクセシビリティ

- **Fcitx5**: ^5.1.0 - 入力メソッド
- **Karabiner-Elements**: ^15.0.0 - キーボードカスタマイズ

## ブラウザ・Web

- **Chrome**: ^120.0.0 - Web ブラウザ
- **Brave**: ^1.60.0 - プライバシー重視ブラウザ

## 重要な制約事項

- **Chezmoi 設定**: `home/.chezmoi.toml.tmpl` でのみ管理
- **暗号化ファイル**: `age`暗号化で管理（`*.age`拡張子）
- **シークレット管理**: Bitwarden CLI 経由でのみアクセス
- **OS 別設定**: テンプレート変数による環境別分岐
- **XDG 準拠**: XDG Base Directory Specification に準拠

## 実装規則

- 命名規則は `chezmoi` の設計に従い `.` は `dot_` に置き換える
- `.tmpl` をつけることで Go Template 構文を使用できる
- 設定ファイルは `home/private_dot_config/` に配置
- シェルスクリプトは `home/.chezmoiscripts/` に配置
- 暗号化ファイルは `age` で暗号化
- OS 別設定は `.chezmoi.toml.tmpl` のテンプレート変数で制御
- パッケージ管理は `.chezmoidata/packages.yaml` `Brewfile` で管理
- ツール、ランタイムは `mise` `~/.config/mise/config.toml` で管理

## パッケージ管理

この dotfiles システムは複数のプラットフォームにわたって複数のパッケージ管理システムをサポートし、ソフトウェア依存関係を管理する統一的なアプローチを提供します。

### Homebrew (macOS)

[Brewfile](../home/private_dot_config/Brewfile)を通じて以下のカテゴリでパッケージを管理します：

#### Formulae（コマンドラインツール）

- 開発ツール（git, vim 等）
- システムユーティリティ（bat, fzf 等）
- ネットワークツール（nmap, whois 等）

#### アプリケーション（Cask）

- 開発環境（VSCode, Cursor 等）
- ブラウザ（Brave, Chrome 等）
- ユーティリティ（AppCleaner, Rectangle 等）
- フォント（HackGen Nerd 等）

#### Mac App Store（mas）

- 生産性アプリ（Microsoft Excel 等）
- 開発ツール（Xcode 等）
- ユーティリティ（LINE, Shazam 等）

### Mise（ランタイム管理）

- [.tool-versions](../.tool-versions)：プログラミング言語バージョン管理
- [mise 設定](../home/private_dot_config/mise)：ツール固有の設定
- Node.js、Python、Go 等のバージョン管理
- 追加ランタイムバージョン管理

### APT（Ubuntu/Debian）

- インストールスクリプトによるシステムパッケージ管理
- 開発依存関係
- Linux 用 GUI アプリケーション

### 統一パッケージデータ管理

[packages.yaml](../home/.chezmoidata/packages.yaml)でクロスプラットフォームパッケージを定義：

```yaml
packages:
  darwin:
    formula: ["git", "curl", "vim", "mise", "bat", "fzf"]
    cask: ["alacritty", "cursor", "brave-browser"]
    mas: ["Microsoft Excel", "Xcode"]

  linux:
    apt: ["git", "curl", "vim", "build-essential"]
    snap: ["code", "discord"]

  windows:
    winget: ["Microsoft.PowerShell", "twpayne.chezmoi"]
    scoop: ["git", "curl", "make", "mise"]

  # Language runtimes (cross-platform)
  mise:
    - "node@latest"
    - "python@latest"
    - "rust@stable"
    - "go@latest"
    - "java@latest"

  # Package manager specific
  cargo: ["starship", "bat", "fd-find", "ripgrep"]
  npm: ["wrangler", "bitwarden-cli", "pm2"]
```

### Chezmoi スクリプト統合

#### OS 固有のインストールスクリプト

```bash
# .chezmoiscripts/darwin/setup.sh.tmpl
{{- range .packages.darwin.formula }}
brew install {{ . }}
{{- end }}

{{- range .packages.darwin.cask }}
brew install --cask {{ . }}
{{- end }}
```

#### 条件付きパッケージインストール

```bash
# 対話環境でのみインストール
{{- if not (or (env "CI") (env "CODESPACES")) }}
{{- range .packages.darwin.cask }}
brew install --cask {{ . }}
{{- end }}
{{- end }}
```

### パッケージ追加ガイドライン

#### Homebrew パッケージ

1. Brewfile の適切なセクションに新しいパッケージを追加
2. 将来使用するためにコメントアウトしたパッケージを保持
3. パッケージに説明的なコメントを追加
4. 関連するパッケージをグループ化

#### ランタイムバージョン

1. 再現性のため`.tool-versions`でバージョンを管理
2. 再現性のため正確なバージョンを指定
3. 異なる環境間での互換性をテスト

#### システムパッケージ

1. インストールスクリプトで依存関係を文書化
2. 異なる OS バージョン間でのパッケージ可用性を確認
3. 可能な場合はフォールバックオプションを提供

#### 外部バイナリ管理

`.chezmoiexternal.toml.tmpl`で直接バイナリを管理：

```toml
# GitHub Releaseから最新のバイナリを取得
[".local/bin/age"]
    type = "archive-file"
    url = {{ gitHubLatestReleaseAssetURL "FiloSottile/age" (printf "age-*-%s-%s.tar.gz" .chezmoi.os .chezmoi.arch) | quote }}
    executable = true
    path = "age/age"
    refreshPeriod = "168h"

# クロスプラットフォーム対応
[".local/bin/fastfetch"]
    type = "archive-file"
    url = {{ gitHubLatestReleaseAssetURL "fastfetch-cli/fastfetch" (printf "fastfetch-*-%s-%s.tar.gz" .chezmoi.os .chezmoi.arch) | quote }}
    executable = true
    path = "fastfetch"
```

### ベストプラクティス

#### セキュリティ

1. `brew update && brew upgrade`で定期的に更新
2. セキュリティパッチのためランタイムバージョンを最新に保持
3. パッケージソースとメンテナを検証

#### メンテナンス

1. 未使用パッケージを適切に削除
2. 再現可能な環境のためバージョン管理を使用
3. パッケージの目的と依存関係を文書化
4. インストールスクリプトを定期的にテスト

#### クロスプラットフォーム互換性

1. 必要に応じて OS 固有のテンプレートを使用
2. 異なるプラットフォームのための代替手段を提供
3. 異なる OS バージョン間でインストールをテスト

#### Chezmoi テンプレート活用

```go
# OS固有のパッケージ管理
{{ if eq .chezmoi.os "darwin" }}
# macOS固有パッケージ
{{ range .packages.darwin.formula }}
brew install {{ . }}
{{ end }}
{{ else if eq .chezmoi.os "linux" }}
# Linux固有パッケージ
{{ range .packages.linux.apt }}
sudo apt-get install -y {{ . }}
{{ end }}
{{ end }}

# アーキテクチャ対応
{{ $arch := .chezmoi.arch }}
{{ if eq $arch "amd64" }}x86_64{{ else }}{{ $arch }}{{ end }}
```

#### エラーハンドリング

```bash
# パッケージインストールのエラーハンドリング
if command -v brew >/dev/null; then
    brew install {{ .package }} || echo "Failed to install {{ .package }}"
elif command -v apt-get >/dev/null; then
    sudo apt-get install -y {{ .package }} || echo "Failed to install {{ .package }}"
else
    echo "No supported package manager found"
fi
```

### 高度なパッケージ管理

#### 環境固有パッケージ

```yaml
packages:
  development:
    formula: ["docker", "kubernetes-cli", "terraform"]
    cask: ["docker", "postman"]

  production:
    formula: ["monitoring-tools", "security-tools"]
```

#### バージョン固定戦略

```toml
# 特定バージョンでの.tool-versions
node 18.17.0
python 3.11.4
go 1.21.0

# 自動更新のMise設定
[tools]
node = "latest"
python = "latest"
```

#### パッケージグループと依存関係

```yaml
groups:
  web-development:
    - node@latest
    - npm-packages: ["typescript", "vite", "eslint"]
    - vscode-extensions: ["ms-vscode.vscode-typescript-next"]

  data-science:
    - python@latest
    - pip-packages: ["jupyter", "pandas", "numpy"]
    - conda-packages: ["scipy", "matplotlib"]
```

#### CI/CD 統合

```bash
# GitHub Actionsの例
- name: Install packages
  run: |
    {{- if eq .chezmoi.os "linux" }}
    sudo apt-get update
    {{- range .packages.linux.apt }}
    sudo apt-get install -y {{ . }}
    {{- end }}
    {{- end }}
```

## 関連ドキュメント

- [要件定義](./requirements.md)
- [設計書](./design.md) - Makefile 設計
- [タスク管理](./tasks.md)
- [ディレクトリ構成](./directory.md) - Chezmoi 設計とワークフロー
