---
name: security
description: dotfiles セキュリティ — 脅威モデルとレビューチェックリスト
---

# セキュリティガイド

このリポジトリの秘密情報・信頼境界・供給鎖リスクの整理です。プロのペンテストの代替ではありません。実施タイミングは [ROADMAP.md](../ROADMAP.md) の M4 と、対象変更の完了条件に従います。

## 秘密の境界（chezmoi vs mise）

| 種類 | 例 | 担当 | パス / 取得方法 |
|------|-----|------|-----------------|
| Chezmoi encrypted dotfile | SSH 鍵、`.env` | **chezmoi** | `encrypted_*`、age passphrase/symmetric |
| age 暗号化済み identity（通常の source ファイル） | `home/key.txt.age` | **スクリプト** | `encrypted_*` ではなく、`.chezmoiignore` の `key.txt*` で deploy 対象外の平文名ファイル。chezmoi は処理せず、`run_once_before_age.sh.tmpl`（`age` が true のときのみ）が `chezmoi age decrypt --passphrase` で `~/.config/chezmoi/key.txt` に復号する。復号後の identity を使う設定・script は repo 内に無い |
| Chezmoi passphrase | encrypted dotfile の復号 | **ユーザー** | `chezmoi apply` / `chezmoi decrypt` 時に手動入力。`run_once_before_age.sh.tmpl` は `key.txt.age` を passphrase で復号し、平文 identity `~/.config/chezmoi/key.txt`（`600`）を生成する（`.chezmoi.toml.tmpl` の `[age]` はこの identity を参照しない） |
| Mise direct-age | ランタイム API キー（age 暗号化した env 値は未使用、ROADMAP M2） | **mise** | `~/.config/mise/age.txt`（raw identity、Chezmoi と分離） |
| GitHub token | Mise の公開 GitHub metadata 取得 | **外部 credential** | CI の `MISE_GITHUB_TOKEN`（repo secret）、Docker build の `GITHUB_TOKEN`（BuildKit secret）、local の `gh` credential fallback |
| CI / Docker | secrets、private key | **テンプレート境界** | `GITHUB_ACTIONS=true`、`DOCKER=true`、encrypted files ignore |

**原則:** Chezmoi は passphrase/symmetric のファイル暗号化を維持。Mise direct-age は runtime env 専用。両者の passphrase/key は共用しない。

## 脅威モデル（要約）

| 資産 | 脅威 | 緩和 |
|------|------|------|
| Chezmoi passphrase | シェル履歴・ログへの露出 | 対話入力。環境変数・source state に保存しない |
| Mise age identity | CI/Docker への混入 | `~/.config/mise/age.txt` を image/source に含めない |
| SSH private key | パーミッション不備。暗号化済みの鍵（`private_dot_ssh/encrypted_*.age`、`key.txt.age`）は公開リポジトリにあり、`ipfs.yaml` が履歴の mirror を IPFS に pin するため、オフライン総当たりに晒され、漏えいしても履歴から撤回できない（ROADMAP M8-1）。安全性は passphrase の強度だけに依存する。`home/private_dot_config/ipfs/` はツリーから削除済みだが、旧 PrivKey は git 履歴と IPFS mirror に残る | `encrypted_*`（scrypt passphrase）、`chezmoi verify`、private mode |
| GitHub token | ログ・image layer への混入。ローカルの `.env` / `.devcontainer/.env`（`.gitignore` 済み）に平文の GitHub PAT が残っている | CI の既存 token、local `gh` fallback。`ARG`/`ENV` に保存しない。PAT の失効・再発行は未実施（ユーザー作業） |
| devcontainer | ビルド時の秘密混入。公開 Full image の既定認証情報（`CMD ["ubuntu", "ubuntu", "yes"]` = パスワード `ubuntu`、`NOPASSWD:ALL`、`EXPOSE 3389`）。Slim image も同様に `CMD ["ubuntu", "ubuntu", "no"]` = パスワード `ubuntu`、`ubuntu` / 開発ユーザーに `NOPASSWD:ALL`（`slim.Dockerfile:86,90`）、`EXPOSE 22`（`openssh-server` 入り）。Dockerfile の「NOPASSWD は付かない」というコメント（第3引数の説明）は誤りで、第3引数が `no` でも sudoers で付与される | `DOCKER=true`、encrypted files ignore、Dockerfile に secrets なし（BuildKit secret のみ）。既定パスワードは image 側では未対処で、`make docker-run` / compose は `127.0.0.1` にのみ公開する |
| 外部アーカイブ | tag drift / API rate limit | age GitHub external を使用しない。`.chezmoiexternal.toml` の fonts は tag 固定だが、cheat・WhiteSur ×4 は `master` / `main` のブランチ先端を参照し固定されていない |
| mise 設定 | cwd より上位の `.env` や設定ファイルの混入 | `trusted_config_paths` は `~/dotfiles` と `~/.local/share/chezmoi` のみ。グローバルの `env_file = '.env'` は設定している（`mise/conf.d/settings.toml`）。cwd と全ての親ディレクトリの `.env` を trust 確認も変数の絞り込みも無しで読み、`LD_PRELOAD` / `NODE_OPTIONS` 等も export されるため、clone した未信頼 repo の `.env` が緩和なしで効く。`~/.env` は chezmoi が `encrypted_private_dot_env.age`（age パスフレーズ暗号。公開リポジトリにあり、守るのはパスフレーズのみ）から配置し、mise は dotenv を復号できない。`yes` は設定しない（`paranoid` は無効）。リポジトリ直下 `mise.toml` の `[env] _.file = '.env'` はコメントアウト中 |
| macOS Gatekeeper | 未確認アプリの実行ダイアログ | 緩和なし。`mise.toml` の `LSQuarantine = false` で意図的に無効化している |


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
| S8 | 外部 URL と install script が supply-chain 境界内にある | `.chezmoiexternal.toml` / scripts review |

### 実施ゲート

| ゲート | 必須 |
|--------|------|
| 移行前 | S1–S4 |
| Mise runtime age 使用前 | S5–S7 |
| 外部 URL / bootstrap 変更時 | S8 |

## Open findings

監査・レビューの正式な指摘一覧はまだ無い。当面は、上の脅威モデルが「未対処」と明記している項目を open として扱う。

- 平文の GitHub PAT がローカルの `.env` / `.devcontainer/.env` に残っている。失効・再発行は未実施（ユーザー作業）
- 公開 Full / Slim image の既定パスワード `ubuntu` と `NOPASSWD:ALL`。image 側では未対処で、`make docker-run` / compose が `127.0.0.1` にのみ公開することでしのいでいる
- 外部アーカイブのうち cheat と WhiteSur ×4 が `master` / `main` のブランチ先端を参照しており、tag 固定されていない
- 暗号化済み秘密鍵が公開リポジトリと IPFS mirror に残り、安全性が passphrase の強度だけに依存する（ROADMAP M8-1）
- グローバルの `env_file = '.env'` が、trust 確認なしで親ディレクトリの `.env` を読む

## 関連

- [README.md の Platform rules](../README.md#platform-rules)
- `home/.chezmoi.toml.tmpl`, `home/.chezmoiignore`
- `home/private_dot_config/mise/conf.d/settings.toml`（`age.key_file`）
- [ROADMAP.md](../ROADMAP.md)

## 監査チェックリスト

移行前 baseline と変更後に、次を確認する:

1. `chezmoi managed/unmanaged/ignored` と `.chezmoiscripts` の所有境界
2. `encrypted_*`、CI/Docker の secret 除外、外部 URL の固定
3. package parity と二重 apply の冪等性
4. `chezmoi verify`、秘密情報を含まないログ、rollback 手順

詳細な実施順序は `ROADMAP.md` の M4 と対象変更の完了条件に従う。
