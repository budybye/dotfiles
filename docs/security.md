---
name: security
description: dotfiles セキュリティ — 脅威モデルとレビューチェックリスト
---

# セキュリティガイド

このリポジトリの秘密情報・信頼境界・供給鎖リスクの整理です。プロのペンテストの代替ではありません。実施タイミングは `openspec/changes/chezmoi-to-mise-migration/tasks.md` §11 を参照。

## 秘密の境界（chezmoi vs mise）

| 種類 | 例 | 担当 | パス / 取得方法 |
|------|-----|------|-----------------|
| Chezmoi encrypted dotfile | SSH 鍵、`.env` | **chezmoi** | `encrypted_*`、age passphrase/symmetric |
| Chezmoi passphrase | encrypted dotfile の復号 | **ユーザー** | `chezmoi apply` / `chezmoi decrypt` 時に手動入力 |
| Mise direct-age | ランタイム API キー | **mise** | `~/.config/mise/age.txt`（raw identity、Chezmoi と分離） |
| GitHub token | Mise の公開 GitHub metadata 取得 | **外部 credential** | CI の `GITHUB_TOKEN`、local の `gh` credential fallback |
| CI / Docker | secrets、private key | **テンプレート境界** | `GITHUB_ACTIONS=true`、`DOCKER=true`、encrypted files ignore |

**原則:** Chezmoi は passphrase/symmetric のファイル暗号化を維持。Mise direct-age は runtime env 専用。両者の passphrase/key は共用しない。

## 脅威モデル（要約）

| 資産 | 脅威 | 緩和 |
|------|------|------|
| Chezmoi passphrase | シェル履歴・ログへの露出 | 対話入力。環境変数・source state に保存しない |
| Mise age identity | CI/Docker への混入 | `~/.config/mise/age.txt` を image/source に含めない |
| SSH private key | パーミッション不備 | `encrypted_*`、`chezmoi verify`、private mode |
| GitHub token | ログ・image layer への混入 | CI の既存 token、local `gh` fallback。`ARG`/`ENV` に保存しない |
| devcontainer | ビルド時の秘密混入 | `DOCKER=true`、encrypted files ignore、Dockerfile に secrets なし |
| 外部アーカイブ | tag drift / API rate limit | age GitHub external を使用しない。URL は固定または Mise cache |


## レビューチェックリスト S1–S8

| # | 確認 | 方法 |
|---|------|------|
| S1 | `home/` に平文秘密がない | secret scan、encrypted inventory |
| S2 | Chezmoi encrypted files が passphrase で復号できる | `chezmoi decrypt` |
| S3 | CI/Docker が encrypted files を処理しない | `chezmoi ignored`、template render |
| S4 | Dockerfile に private key/token がない | Dockerfile / build log 確認 |
| S5 | GitHub token が source state/image layer にない | `GITHUB_TOKEN` / `MISE_GITHUB_TOKEN` の経路確認 |
| S6 | age identity の権限が `600` | `stat ~/.config/mise/age.txt` |
| S7 | Mise `age.strict` が意図せず無効化されていない | Mise config review |
| S8 | 外部 URL と install script が supply-chain 境界内にある | `.chezmoiexternal.toml.tmpl` / scripts review |

### 実施ゲート

| ゲート | 必須 |
|--------|------|
| 移行前 | S1–S4 |
| Mise runtime age 使用前 | S5–S7 |
| 外部 URL / bootstrap 変更時 | S8 |

## Open findings

| ID | 重大度 | 内容 | 状態 | 担当 Phase |
|----|--------|------|------|------------|
| — | — | （監査・レビュー実施後に記載） | — | — |

## 関連

- [audit-checklist.md](audit-checklist.md)
- [bootstrap.md](bootstrap.md)
- `home/.chezmoi.toml.tmpl`, `home/.chezmoiignore`
- `home/private_dot_config/mise/config.toml`
- OpenSpec: `openspec/changes/chezmoi-to-mise-migration/design.md` — **Security review**
