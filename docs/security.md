---
name: security
description: セキュリティ方針・暗号化・シークレット管理・SSH・CI 環境の扱い
---

# セキュリティ - Chezmoi Dotfiles Management System

## 概要・方針

このプロジェクトは**セキュリティ優先設計**を採用しています。機密情報の暗号化、パスワードマネージャー統合、SSH 鍵の安全な管理により、dotfiles をリポジトリで管理しながらシークレットの漏洩を防ぎます。

- **暗号化**: age による `*.age` ファイルの暗号化
- **シークレット管理**: age 暗号化ファイル（環境変数）または Bitwarden/1Password CLI（Git設定）経由
- **SSH 鍵**: 暗号化秘密鍵（`encrypted_*.age`）で管理
- **アクセス制御**: ファイル属性による権限管理

参照: [要件定義 - セキュリティ](requirements.md#セキュリティ), [設計書 - セキュリティ設計](design.md#セキュリティ設計)

---

## 暗号化（age）

### 概要

機密ファイルは [age](https://age-encryption.org/) で暗号化し、`*.age` 拡張子でリポジトリにコミットします。復号にはパスフレーズまたは identity ファイルが必要です。

### 鍵生成

```sh
make age-keygen
```

パスフレーズ保護付きの新しい age 暗号化キーを生成します。詳細は [設計書 - セキュリティコマンド](design.md#age-keygen) を参照。

### ファイルの暗号化

```sh
# パスフレーズ対称暗号化の例
age --armor --passphrase | age --decrypt --output key.txt
```

chezmoi で機密ファイルを追加する際は、`encrypted_` プレフィックスと `*.age` 拡張子を使用します。

### key.txt 復号フロー

初回 `chezmoi apply` 時、`run_once_before_age.sh.tmpl` が実行されます。

1. **age のインストール**: mise → brew → apt の順で試行
2. **key.txt の復号**: `~/.config/chezmoi/key.txt` が存在しない場合、`key.txt.age` をパスフレーズで復号
3. **identity の配置**: 復号した key.txt を `~/.config/chezmoi/key.txt` に配置（chmod 600）

参照: [home/.chezmoiscripts/run_once_before_age.sh.tmpl](../home/.chezmoiscripts/run_once_before_age.sh.tmpl)

### 除外ファイル

`.chezmoiignore` により以下は適用対象外です。

- `key.txt.age` - 復号キー本体（リポジトリに含めない）
- `shhh.txt` - 一時的な暗号化出力

### 環境別の age 有効/無効

`home/.chezmoi.toml.tmpl` で `$age` フラグを制御しています。

| 環境                                                  | age  |
| ----------------------------------------------------- | ---- |
| GITHUB_ACTIONS, CODESPACES, REMOTE_CONTAINERS, DOCKER | 無効 |
| ユーザー root, ubuntu, dev, vscode, runner            | 無効 |
| ユーザー budybye, hotmilk（Mac）                      | 有効 |
| その他                                                | 無効 |

---

## シークレット管理（Bitwarden）

### シークレット概要

Git の user.name / user.email は、Bitwarden CLI 経由で取得します。`make bw-unlock` で vault をアンロックし、環境変数を設定してから `chezmoi apply` を実行します。

**環境変数スクリプト**（API キー等）は age 暗号化ファイル（`encrypted_private_executable_envars.age`）として管理します。Bitwarden からの移行により、オフラインでの利用が可能になりました。

### コマンド

```sh
make bw-unlock
```

Bitwarden vault をアンロックし、chezmoi 用の環境変数を設定します。詳細は [設計書 - bw-unlock](design.md#bw-unlock) を参照。

### chezmoi テンプレートでの利用

テンプレート内で `bitwarden "item" "gh"` 等の関数を呼び出し、ログイン情報を取得します。

### .chezmoiignore の bitwarden 条件

`$bitwarden` が false の場合、以下が適用対象外になります。

- `.config/git/user*`
- `.ssh/id_ed25519*`, `.ssh/id_rsa*`
- `.config/cursor/mcp.json`, `.config/claude/settings.json`
- `.chezmoiscripts/bw.sh`

参照: [home/.chezmoiignore](../home/.chezmoiignore)

---

## SSH 鍵管理

### 暗号化秘密鍵

SSH 秘密鍵は age で暗号化し、リポジトリに含めます。

- `home/dot_ssh/encrypted_private_id_ed25519.age`
- `home/dot_ssh/encrypted_private_id_rsa.age`

適用時に age で復号し、`~/.ssh/id_ed25519` 等に配置されます。

### authorized_keys

`home/dot_ssh/authorized_keys.tmpl` で GitHub から公開鍵を取得して配置します。CI 環境（GITHUB_ACTIONS）では適用されません。

### .chezmoiignore の SSH 条件

| 条件            | 除外対象                                                     |
| --------------- | ------------------------------------------------------------ |
| `$age` が false | `.ssh/id_rsa*`, `.ssh/id_ed25519*`, `.chezmoiscripts/age.sh` |
| `$ssh` が false | `.ssh/**`                                                    |
| GITHUB_ACTIONS  | `.ssh/authorized_keys*`, `.ssh/id_ed25519*`, `.ssh/id_rsa*`  |

---

## CI 環境での扱い

### GitHub Actions

`GITHUB_ACTIONS=true` の場合、以下が適用されます。

1. **age 暗号化**: 無効（`encryption = "age"` を設定しない）
2. **SSH 鍵**: authorized_keys、id_ed25519、id_rsa を除外
3. **Bitwarden / age フラグ**: ともに false

これにより、CI では暗号化ファイルの復号やシークレット取得を行わず、設定の差分チェック等のみ実行できます。

参照: [home/.chezmoi.toml.tmpl](../home/.chezmoi.toml.tmpl) L21-24, L96-105, [home/.chezmoiignore](../home/.chezmoiignore) L10-16

---

## GitHub CLI (gh) の注意

### キーリングと hosts.yml

gh は認証トークンを**システムのキーリング**に保存します（macOS Keychain、Linux GNOME Keyring、Windows Credential Manager）。キーリングが利用できない場合は `~/.config/gh/hosts.yml` にプレーンテキストでフォールバックします。

| 項目             | 内容                                                      |
| ---------------- | --------------------------------------------------------- |
| 設定ディレクトリ | `~/.config/gh/`（XDG_CONFIG_HOME を尊重）                 |
| ホスト設定       | `hosts.yml`（トークンはキーリング使用時は含まれない）     |
| 保存先確認       | `gh auth status` で「keyring」または「config file」と表示 |

### --insecure-storage の危険性

`gh auth login --insecure-storage` 使用時は OAuth トークンが `hosts.yml` にプレーンテキストで書き込まれます。その状態でコミットすると漏洩リスクがあるため、当該ファイルを `.gitignore` に追加するか、chezmoi 管理から外すことを検討してください。**通常運用ではキーリングを使用し、`--insecure-storage` は避けてください。**

### サンドボックス環境との相性

emdash 等の AI エージェント開発環境では、gh がキーリングに保存した認証情報にアクセスできない場合があります。対処として `GH_TOKEN` を環境変数で渡す方法があります。

詳細は [環境差の注意点 - GitHub CLI 資格情報保存](problems.md#github-cli-gh-資格情報保存) を参照。

---

## インシデント対応

### 漏洩が疑われる場合

1. **age 鍵の漏洩**: 新しい鍵を生成（`make age-keygen`）し、全 `*.age` ファイルを再暗号化。旧鍵で暗号化したファイルは破棄または再生成
2. **Bitwarden 漏洩**: Bitwarden のマスターパスワード変更、該当アイテムのパスワード変更
3. **SSH 鍵の漏洩**: 新しい鍵ペアを生成し、GitHub 等の authorized keys を更新。旧鍵を無効化
4. **gh トークン漏洩**: GitHub の Settings → Developer settings → Personal access tokens で該当トークンを revoke

### 予防

- `key.txt.age`、`shhh.txt` は `.chezmoiignore` でリポジトリに含めない
- キーリングを利用し、`--insecure-storage` は使用しない
- 定期的にセキュリティパッチを適用（[タスク管理 - セキュリティパッチ適用](tasks.md)）

---

## 関連ドキュメント

- [設計書](design.md) - セキュリティ設計、Makefile セキュリティコマンド
- [要件定義](requirements.md) - セキュリティ要件
- [技術スタック](tech.md) - Age, Bitwarden, SSH の技術一覧
- [ディレクトリ構成](directory.md) - 暗号化ファイルの配置、Chezmoi 暗号化手順
- [環境差の注意点](problems.md) - gh キーリング、プラットフォーム差
- [タスク管理](tasks.md) - セキュリティパッチ適用

### 外部リンク

- [Age 暗号化ツール](https://age-encryption.org/)
- [Bitwarden CLI](https://bitwarden.com/help/cli/)
- [Chezmoi 暗号化](https://chezmoi.io/user-guide/encryption/)
- [Chezmoi パスワードマネージャ統合](https://chezmoi.io/user-guide/password-managers/)
