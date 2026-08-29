---
name: security
description: dotfiles セキュリティ — 脅威モデルとレビューチェックリスト
---

# セキュリティガイド

このリポジトリの秘密情報・信頼境界・供給鎖リスクの整理です。プロのペンテストの代替ではありません。実施タイミングは `openspec/changes/chezmoi-to-mise-migration/tasks.md` §11 を参照。

## 秘密の境界（chezmoi vs mise）

| 種類 | 例 | 担当 | パス |
|------|-----|------|------|
| 暗号化 dotfile | SSH 鍵、`.env` | **chezmoi** | `encrypted_*`, `run_once_before_age.sh.tmpl` |
| age 復号鍵 | chezmoi 用 | **chezmoi** | `key.txt.age` → `~/.config/chezmoi/key.txt` |
| Bitwarden セッション | テンプレート用 | **chezmoi** | `run_once_before_bw.sh.tmpl` |
| mise age（将来） | ランタイム API キー | **mise** | `~/.config/mise/age.txt`（chezmoi 鍵と別） |
| CI / Docker | 秘密オフ | **テンプレート** | `DOCKER=true`, `GITHUB_ACTIONS=true` |

**原則:** Phase 1–3 では chezmoi がファイル単位の暗号化を維持。mise の age はランタイム env 用のみ（Phase 3+）。

## 脅威モデル（要約）

| 資産 | 脅威 | 緩和 |
|------|------|------|
| age 秘密鍵 | CI で誤って有効化 | `features.age` / env オーバーレイ |
| BW トークン | ログ・シェル env 漏洩 | `before_bw`、非対話 CI では無効 |
| SSH 秘密鍵 | パーミッション不備 | `encrypted_*`, `chezmoi verify` |
| `curl \| sh` | 供給鎖 | `install.sh` / mise.run のみ文書化；タスクは URL 固定 |
| devcontainer | ビルド時に秘密混入 | `DOCKER=true`、Dockerfile に秘密なし |
| 外部アーカイブ | タグ漂流 | `.chezmoiexternal.toml.tmpl` ピン留め |

## レビューチェックリスト S1–S10

| # | 確認 | 方法 |
|---|------|------|
| S1 | 直近の `home/` に平文秘密がない | `git log -p` / secret scan |
| S2 | CI プロファイルで age 鍵なし dry-run 可 | `chezmoi apply --dry-run` + `GITHUB_ACTIONS=true` |
| S3 | CI で `age`/`bitwarden` が true にならない | `chezmoi data` |
| S4 | Dockerfile に秘密 env なし | Dockerfile / ビルドログ確認 |
| S5 | 文書化外の `curl \| sh` がない | grep `install.sh`, `.chezmoiscripts`, `[tasks]` |
| S6 | 鍵・設定のパーミッション | `chezmoi verify` |
| S7 | sandbox で secret 派生パスが ignore | `chezmoi ignored` プロファイル比較 |
| S8 | mise タスクが秘密をログしない | タスク script レビュー |
| S9 | agent skills の供給鎖 | `packages.yaml` `agents.skills` 監査 |
| S10 | `features.*` の typo で秘密復活しない | fixture テスト（Phase 4 後） |

### 実施ゲート

| ゲート | 必須 |
|--------|------|
| §5 スクリプト retire 前 | S1–S6 |
| Phase 1 完了後 | S5, S8 |
| Phase 4 context 後 | S3, S7, S10 |
| mise runtime secrets 有効化前 | S2 分離 + 本 doc 更新 |

## Open findings

| ID | 重大度 | 内容 | 状態 | 担当 Phase |
|----|--------|------|------|------------|
| — | — | （監査・レビュー実施後に記載） | — | — |

## 関連

- [audit-checklist.md](audit-checklist.md)
- [bootstrap.md](bootstrap.md)（作成予定）
- `home/.chezmoi.toml.tmpl`, `run_once_before_age.sh.tmpl`, `run_once_before_bw.sh.tmpl`
- `maximize-chezmoi-features` §4 Secrets and external resources
- OpenSpec: `openspec/changes/chezmoi-to-mise-migration/design.md` — **Security review**
