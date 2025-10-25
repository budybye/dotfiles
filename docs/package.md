# パッケージ管理ガイド

## 概要

このdotfilesシステムは複数のプラットフォームにわたって複数のパッケージ管理システムをサポートし、ソフトウェア依存関係を管理する統一的なアプローチを提供します。

## パッケージ管理システム

### Homebrew (macOS)

[Brewfile](../home/private_dot_config/Brewfile)を通じて以下のカテゴリでパッケージを管理します：

#### Formulae（コマンドラインツール）

- 開発ツール（git, vim等）
- システムユーティリティ（bat, fzf等）
- ネットワークツール（nmap, whois等）

#### アプリケーション（Cask）

- 開発環境（VSCode, Cursor等）
- ブラウザ（Brave, Chrome等）
- ユーティリティ（AppCleaner, Rectangle等）
- フォント（HackGen Nerd等）

#### Mac App Store（mas）

- 生産性アプリ（Microsoft Excel等）
- 開発ツール（Xcode等）
- ユーティリティ（LINE, Shazam等）

### Mise（ランタイム管理）

- [.tool-versions](../.tool-versions)：プログラミング言語バージョン管理
- [mise設定](../home/private_dot_config/mise)：ツール固有の設定
- Node.js、Python、Go等のバージョン管理
- 追加ランタイムバージョン管理

### APT（Ubuntu/Debian）

- インストールスクリプトによるシステムパッケージ管理
- 開発依存関係
- Linux用GUIアプリケーション

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

## Chezmoiスクリプト統合

### OS固有のインストールスクリプト

```bash
# .chezmoiscripts/darwin/setup.sh.tmpl
{{- range .packages.darwin.formula }}
brew install {{ . }}
{{- end }}

{{- range .packages.darwin.cask }}
brew install --cask {{ . }}
{{- end }}
```

### 条件付きパッケージインストール

```bash
# 対話環境でのみインストール
{{- if not (or (env "CI") (env "CODESPACES")) }}
{{- range .packages.darwin.cask }}
brew install --cask {{ . }}
{{- end }}
{{- end }}
```

## パッケージ追加ガイドライン

### Homebrewパッケージ

1. Brewfileの適切なセクションに新しいパッケージを追加
2. 将来使用するためにコメントアウトしたパッケージを保持
3. パッケージに説明的なコメントを追加
4. 関連するパッケージをグループ化

### ランタイムバージョン

1. 再現性のため`.tool-versions`でバージョンを管理
2. 再現性のため正確なバージョンを指定
3. 異なる環境間での互換性をテスト

### システムパッケージ

1. インストールスクリプトで依存関係を文書化
2. 異なるOSバージョン間でのパッケージ可用性を確認
3. 可能な場合はフォールバックオプションを提供

### 外部バイナリ管理

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

## ベストプラクティス

### セキュリティ

1. `brew update && brew upgrade`で定期的に更新
2. セキュリティパッチのためランタイムバージョンを最新に保持
3. パッケージソースとメンテナを検証

### メンテナンス

1. 未使用パッケージを適切に削除
2. 再現可能な環境のためバージョン管理を使用
3. パッケージの目的と依存関係を文書化
4. インストールスクリプトを定期的にテスト

### クロスプラットフォーム互換性

1. 必要に応じてOS固有のテンプレートを使用
2. 異なるプラットフォームのための代替手段を提供
3. 異なるOSバージョン間でインストールをテスト

### Chezmoiテンプレート活用

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

### エラーハンドリング

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

## 高度なパッケージ管理

### 環境固有パッケージ

```yaml
packages:
  development:
    formula: ["docker", "kubernetes-cli", "terraform"]
    cask: ["docker", "postman"]

  production:
    formula: ["monitoring-tools", "security-tools"]
```

### バージョン固定戦略

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

### パッケージグループと依存関係

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

### CI/CD統合

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
