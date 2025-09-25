# Chezmoi設定ガイド

## 概要

このプロジェクトは、[twpayne/dotfiles](https://github.com/twpayne/dotfiles)とchezmoiのベストプラクティスに基づいて構築されたchezmoiを使用したdotfile管理システムです。

## コアディレクトリ

- `home/`: ホームディレクトリ設定ファイル（chezmoiソース状態）
- `.chezmoiroot`: Chezmoiルートディレクトリマーカー（`home`を指す）
- `.tool-versions`: mise/asdf互換バージョン管理ファイル

## Chezmoi設定ファイル

- [.chezmoi.toml.tmpl](home/.chezmoi.toml.tmpl): メインchezmoi設定テンプレート
- [.chezmoiexternal.toml.tmpl](home/.chezmoiexternal.toml.tmpl): 外部ファイルとアーカイブ管理
- [.chezmoiignore](home/.chezmoiignore): chezmoiで無視するファイル
- [.chezmoidata/](home/.chezmoidata/): テンプレート変数データ

## Chezmoiディレクトリ構造

### ファイル属性プレフィックス

Chezmoiはファイル名にメタデータを埋め込んで適切な属性を自動的に適用します：

- `dot_*`: `dot_`プレフィックスがdotfilesになる（例：`dot_zshrc` → `.zshrc`）
- `private_*`: 制限されたパーミッション用`private_`プレフィックス（0600）
- `encrypted_*`: age暗号化用`encrypted_`プレフィックス
- `executable_*`: 実行可能スクリプト用`executable_`プレフィックス
- `symlink_*`: シンボリックリンク用`symlink_`プレフィックス
- `readonly_*`: 読み取り専用用`readonly_`プレフィックス（0444）

### テンプレートファイル

- `.tmpl`拡張子: chezmoiテンプレートとして処理
- `.chezmoitemplates/`: 共有テンプレートコンポーネント

### スクリプトディレクトリ組織

Chezmoiは`.chezmoiscripts/`内のスクリプトを自動的に実行します：

#### OS固有スクリプト

- `darwin/`: macOS固有スクリプト
- `linux/`: Linux固有スクリプト
- `windows/`: Windows固有スクリプト

#### スクリプト命名規則

- `run_*`: `chezmoi apply`中に実行
- `run_once_*`: 一度だけ実行
- `run_onchange_*`: コンテンツが変更されたときに実行
- `run_before_*`: ファイルインストール前に実行
- `run_after_*`: ファイルインストール後に実行

## 外部ファイル管理

`.chezmoiexternal.toml.tmpl`で外部リソースを管理：

### サポートされるタイプ

- `file`: 単一ファイルダウンロード
- `archive`: アーカイブを展開
- `archive-file`: アーカイブから特定ファイルを展開
- `git-repo`: Gitリポジトリのクローン/更新

### 設定例

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

## テンプレート変数システム

### 組み込み変数

- OS固有設定: `{{ if eq .chezmoi.os "darwin" }}`
- アーキテクチャ設定: `{{ .chezmoi.arch }}`
- ユーザ情報: `{{ .chezmoi.username }}`
- ホスト情報: `{{ .chezmoi.hostname }}`

### カスタムデータ

- `.chezmoidata/`ディレクトリ内のYAML/TOML/JSONファイル
- `.chezmoi.toml.tmpl`の`[data]`セクション
- 環境変数: `{{ env "VAR_NAME" }}`

### パスワードマネージャ統合

```go
{{ bitwarden "item" "name" }}
{{ onepassword "vault" "item" "field" }}
{{ keepassxc "database" "entry" "attribute" }}
```

## 日常ワークフロー

### 日常操作

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

### ファイル管理

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

## Goテンプレート

### テンプレート構文

- Go text/templateを拡張したsprig関数ライブラリを活用
- OS固有設定に`{{ if eq .chezmoi.os "darwin" }}`パターンを使用
- 環境変数アクセスに`{{ env "VAR_NAME" }}`を使用
- `{{ bitwarden "item" "name" }}`等でパスワードマネージャ統合を活用

### 条件付き設定

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

### マルチ環境サポート

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

### 動的外部リソース

```toml
# アーキテクチャに基づいて異なるリソースを取得
{{ $arch := .chezmoi.arch }}
{{ if eq $arch "arm64" }}
[".local/bin/tool"]
    url = "https://releases.com/tool-arm64.tar.gz"
{{ else }}
[".local/bin/tool"]
    url = "https://releases.com/tool-amd64.tar.gz"
{{ end }}
```

### カスタムテンプレート関数

```go
# 設定にカスタムデータを使用
{{ .packages.development | toJson }}
{{ .aliases | keys | sortAlpha }}
{{ printf "%s@%s" .tool.name .tool.version }}
```

## セキュリティと暗号化

### Age暗号化

```sh
# 新しい暗号化キーを生成
make age-keygen

# chezmoiで機密ファイルを暗号化
chezmoi add --encrypt ~/.ssh/private_key

# パスフレーズ対称暗号化
age --armor --passphrase | age --decrypt --output key.txt
```

### Bitwarden統合

```sh
# シークレット管理のためのvaultをアンロック
make bw-unlock

# chezmoi統合でセキュアなシークレット注入
{{ bitwarden "item" "name" }}
```

### Bitwardenシークレット取得

```toml
# .chezmoi.toml.tmplの設定例
[data]
    github_token = {{ bitwarden "items" "name" key.value }}
```

## テストと検証

### ローカルテスト

```sh
# 設定チェックを実行
make check

# 分離されたDocker環境でテスト
make docker-run

# chezmoi設定を検証
chezmoi diff
chezmoi doctor
chezmoi verify
```

### デバッグツール

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

## エラーハンドリングとデバッグ

### 一般的な問題

1. **テンプレート構文エラー**: Goテンプレート構文とsprig関数を確認
2. **暗号化の問題**: ageキー設定と環境を検証
3. **パーミッションの問題**: ファイル属性とumask設定を確認
4. **パス解決**: テンプレートパスと外部ファイルURLを検証

### 信頼性のためのベストプラクティス

1. **必ず変更をテスト**し、最初に分離された環境で行う
2. **すべての設定変更にバージョン管理を使用**
3. **主要な変更前に機密データをバックアップ**
4. **将来の参照のためにカスタム変更を文書化**
5. **外部依存関係の定期メンテナンス**

## ヘルスモニタリング

```sh
# 総合的なシステム情報
make system-info

# リソース一覧
make list-containers
make list-vms

# Chezmoi固有のヘルスチェック
chezmoi doctor
chezmoi verify
chezmoi unmanaged
```

## リファレンスドキュメント

### 優先ドキュメント

1. [Chezmoi公式ユーザーガイド](https://chezmoi.io/user-guide/command-overview/) - コマンド概要とワークフロー
2. [Chezmoiテンプレート機能](https://chezmoi.io/user-guide/templating/) - テンプレート構文とベストプラクティス
3. [Chezmoi外部ファイル管理](https://chezmoi.io/user-guide/include-files-from-elsewhere/) - 外部リソース統合
4. [Chezmoiパスワードマネージャ統合](https://chezmoi.io/user-guide/password-managers/) - シークレット管理
5. [Chezmoi暗号化](https://chezmoi.io/user-guide/encryption/) - Age/GPG暗号化
6. [Chezmoiリファレンス](https://chezmoi.io/reference/) - 完全なAPIリファレンス

### ベストプラクティスリファレンス

- [Tom Payneのdotfiles](https://github.com/twpayne/dotfiles) - Chezmoi作成者によるリファレンス実装
- [Chezmoi設計哲学](https://chezmoi.io/user-guide/frequently-asked-questions/design/) - 設計哲学と制約
- [XDG Base Directory仕様](https://specifications.freedesktop.org/basedir-spec/) - Linuxディレクトリ標準
