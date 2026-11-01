---
name: testing
description: dotfiles のローカル・CI・環境別検証ガイド
---

# 検証ガイド

この文書は、Chezmoi、Mise、bootstrap、CI workflow の変更をどの境界で検証するかを定義します。

## 正本

- Make target: [`Makefile`](../Makefile)
- CI matrix: [`.github/workflows/test.yaml`](../.github/workflows/test.yaml)
- bootstrap / profile 境界: [`architecture.md`](architecture.md)
- OS / CI / Docker の責務: [`requirements.md`](requirements.md#プロファイル要件)
- 実際の package / tool 定義: `home/private_dot_config/mise.toml`（apt / brew / brew-cask）、`home/private_dot_config/Brewfile`（macOS の `bb` / `bcf` 用。bootstrap は適用しない）、`home/private_dot_config/mise/`、`home/.chezmoidata/packages.yaml`（Windows の winget / scoop のみ）

## ローカル検証

### 高速チェック

```bash
make check
make test
make verify
make doctor
```

- `make check`: `chezmoi diff` で適用差分を確認
- `make test`: 空の一時 destination に `chezmoi apply --dry-run` を実行し、現在の OS / profile で適用対象の template を描画する。暗号化ファイルと external は除外し、描画エラーで失敗する。他 OS・CI・Docker 限定の template は対象外で、CI は `make test` を実行しない
- `make verify`: `chezmoi verify` で適用先が source と一致するか確認し、差分があれば失敗する（script の構文検証ではない）
- `make doctor`: Chezmoi の環境診断

秘密情報が必要な処理は、CI や共有ログへ passphrase・token を出力しません。

### 初期化の検証

`make init` は disposable な macOS / Ubuntu 環境で実行します。

```bash
make init
```

初期化後に最低限確認するもの:

```bash
chezmoi doctor
chezmoi diff
mise config ls
```

## 変更種別ごとの検証

| 変更 | 必須確認 |
| --- | --- |
| template / `.chezmoiignore` / `.chezmoidata` | `make test`、`chezmoi execute-template`、`chezmoi diff` |
| shell / lifecycle script | `bash -n` または `zsh -n`、対象範囲の `shellcheck`、`make test` |
| package / Mise profile | `mise config ls`、対象 profile の bootstrap status、platform matrix |
| secrets / encrypted file | 平文を作らないこと、`chezmoi ignored`、秘密情報を含まないログ |
| Dockerfile / Compose | `make docker-build` または `make up`、起動後の service smoke test（build は GitHub 上の `DOTFILES_REF`、既定 `main` を clone するため、未 push の変更は対象外） |
| VM / cloud-init | 対象環境で create → provision 完了 → OS / service の確認 |
| GitHub Actions workflow | YAML 構文、変更 job の実行、失敗時の log / summary |
| docs / path rename | 全リンク、実在パス、README / ROADMAP の参照 |

この表の確認は手動です。CI が実行するのは `make init`（`GITHUB_ACTIONS=true` の 1 profile）、LXD の cloud-init 起動、tag / 日次の image build だけです。`bash -n` / `shellcheck` / `lychee` / hadolint / actionlint / secret scan は workflow にも Make target にもありません。

## CI 検証境界

`.github/workflows/test.yaml` は main push だけで動き（`pull_request` なし）、`docs/**` と `*.md` の変更では動きません。主な job は次の境界を検証します。

| Job | 環境 | 検証 |
| --- | --- | --- |
| `ubuntu-amd64` | Ubuntu amd64 | `make init`（終了コードのみ） |
| `ubuntu-arm64` | Ubuntu arm64 | `make init`（終了コードのみ） |
| `darwin` | macOS | `make init`（終了コードのみ） |
| `lxd` | Ubuntu + LXD | cloud-init、container 起動、OS 情報（cloud-init の終了コードは無視。`make init` は実行しない） |
| `rpi` | Ubuntu arm64 + LXD | `cloud-init/user-data` の cloud-init、OS 情報（cloud-init の終了コードは無視） |
| `powershell` | Windows | Scoop で `curl` / `make` / `git` を入れるだけ（chezmoi は実行しない） |
| `windows-11-arm64` | Windows arm64 | checkout のみ |
| `wsl2` | Windows | checkout のみ（WSL は使わない） |

OrbStack の job は GitHub-hosted macOS の nested virtualization 制約により現在コメントアウトしています。物理 macOS self-hosted runner を導入した場合だけ復帰します。

`GITHUB_ACTIONS=true` のとき `run_once_after_watch.sh` が環境変数名と `mise dr` / `chezmoi doctor` の診断を出力しますが、失敗は無視し、結果は検証しません。`tag.yaml` は `test.yaml` 成功後に tag と release を作って `push.yaml` を起動します。`push.yaml` の日次 schedule は image を公開せず cache を更新するだけです。`ipfs.yaml` は pin だけで検証しません。

## Docker 検証

Docker build は Mise が GitHub metadata を取得できるよう token 経路を確認します。

```bash
GITHUB_TOKEN="$(gh auth token)" make up
```

- token を `.env`、Dockerfile の `ARG` / `ENV`、image layer に保存しない
- Compose の localhost bind と RDP port を確認する（SSH port の行はコメントアウト中）
- Full image と CLI image の責務を混同しない

## 失敗時の確認順

1. 変更された正本ファイルと適用先を特定する
2. `chezmoi diff` と `chezmoi execute-template` の出力を確認する
3. `chezmoi ignored` で意図しない除外を確認する
4. OS、architecture、CI / Docker profile の分岐を確認する
5. CI では失敗した job の最初のエラーと step summary を確認する
6. 秘密情報を削除した再現ログだけを保存する

## 完了条件

- 変更に対応する最小の検証コマンドを実行した
- 変更した platform / profile の境界を検証した
- 失敗時のログに秘密情報が含まれていない
- README、architecture、tech、directory、security の参照が壊れていない
- workflow 変更では該当 job の実行結果を確認した

## 統合後の追加検証

- profile 変更: `mise config ls`、対象 platform の dry-run。package の状態確認は `mise bootstrap packages status`（Linux は apt、macOS は brew / brew-cask）。macOS の `Brewfile` は別に `brew bundle check --file ~/.config/Brewfile` で確認する
- xrdp / GUI 変更: Ubuntu VM と Docker を分けて session smoke test
- template 変更: `chezmoi execute-template`、`chezmoi verify`、`chezmoi diff`
- VCS / keybind / skill manager 変更: 実設定ファイルと対象 command の動作確認
