---
name: test
description: dotfiles のローカル・CI・環境別検証ガイド
---

# 検証ガイド

この文書は、Chezmoi、Mise、bootstrap、CI workflow の変更をどの境界で検証するかを定義します。

## 正本

- Make target: [`Makefile`](../Makefile)
- CI matrix: [`.github/workflows/test.yaml`](../.github/workflows/test.yaml)
- bootstrap / profile 境界: [`architecture.md`](architecture.md)
- OS / CI / Docker の責務: [`requirements.md`](requirements.md#プロファイル要件)
- 実際の package / tool 定義: `home/private_dot_config/mise.toml`、`home/private_dot_config/mise/`、`home/.chezmoidata/packages.yaml`

## ローカル検証

### 高速チェック

```bash
make check
make test
make verify
make doctor
```

- `make check`: `chezmoi diff` で適用差分を確認
- `make test`: template の dry-run と `chezmoi apply --dry-run` を確認
- `make verify`: Chezmoi の source / script を検証
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
| shell / lifecycle script | `bash -n` または `zsh -n`、対象範囲の `shellcheck`、`make verify` |
| package / Mise profile | `mise config ls`、対象 profile の bootstrap status、platform matrix |
| secrets / encrypted file | 平文を作らないこと、`chezmoi ignored`、秘密情報を含まないログ |
| Dockerfile / Compose | `make docker-build` または `make up`、起動後の service smoke test |
| VM / cloud-init | 対象環境で create → provision 完了 → OS / service の確認 |
| GitHub Actions workflow | YAML 構文、変更 job の実行、失敗時の log / summary |
| docs / path rename | 全リンク、実在パス、README / ROADMAP の参照 |

## CI 検証境界

`.github/workflows/test.yaml` の主な job は次の境界を検証します。

| Job | 環境 | 検証 |
| --- | --- | --- |
| `ubuntu-amd64` | Ubuntu amd64 | `make init` |
| `ubuntu-arm64` | Ubuntu arm64 | `make init` |
| `darwin` | macOS | `make init` |
| `lxd` | Ubuntu + LXD | cloud-init、container 起動、OS 情報 |
| `rpi` | Ubuntu arm64 + LXD | cloud-init、OS 情報 |
| `powershell` | Windows | Scoop / CLI bootstrap の入口 |
| `wsl2` | Windows | checkout / runner 境界 |

OrbStack の job は GitHub-hosted macOS の nested virtualization 制約により現在コメントアウトしています。物理 macOS self-hosted runner を導入した場合だけ復帰します。

## Docker 検証

Docker build は Mise が GitHub metadata を取得できるよう token 経路を確認します。

```bash
GITHUB_TOKEN="$(gh auth token)" make up
```

- token を `.env`、Dockerfile の `ARG` / `ENV`、image layer に保存しない
- Compose の localhost bind と RDP / SSH port を確認する
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

- profile 変更: `mise config ls`、`mise bootstrap packages status`、対象 platform の dry-run
- xrdp / GUI 変更: Ubuntu VM と Docker を分けて session smoke test
- template 変更: `chezmoi execute-template`、`chezmoi verify`、`chezmoi diff`
- VCS / keybind / skill manager 変更: 実設定ファイルと対象 command の動作確認
