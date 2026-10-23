---
name: roadmap
description: プロジェクトの目標・進捗・バージョン計画
---

# Roadmap - Chezmoi Dotfiles

## GOAL

**最上位ゴール**: いつ・どの環境でも、自分用に最適化された設定を使える状態を半永続的に維持する (動的)。

完了条件を持たない上位目標であり、優先順位表の外に置く。短期〜長期の全マイルストーン (M5-M7、継続監査 M4) はこのゴールへの手段であり、環境が増える・変わるたびに本ファイルの目標に分解して維持する。

このファイルは、プロジェクトの中長期目標、到達点、進行中の作業、リリース方針を管理します。

README.md と docs/ が運用・設計の正本です。

実装手順と完了条件は本ファイルのマイルストーンに直接記録します。

## 現在地

- Chezmoi がテンプレート、設定、暗号化ファイル、OS・host 分岐を管理する
- Mise がツール、package bootstrap、macOS defaults の正本へ移行中
- Makefile は既存利用者と CI の互換入口として維持する
- GitHub Actions は複数 OS、Docker、LXD、arm64 環境を検証する
- SemVer git tag がリリースバージョンの単一ソースである

## 目標の優先順位

実施順は 短期 → 中期 → 長期。番号は各期間内の優先順位。

| 期間 | 順 | 目標 | 依存・補足 |
|---|---|---|---|
| 完了 | - | M1 ドキュメントと正本の整理 | 残タスクは短期6へ移行 |
| 短期 | 1 | Ubuntu 26.04 環境の安定化 | CI / VM / LXD の土台 |
| 短期 | 2 | Ubuntu profile 境界の整理 | 1 と並行可 |
| 短期 | 3 | cloud-init 最適化 | 1 と並行可 |
| 短期 | 4 | Obsidian vault の git 管理 | 独立 |
| 短期 | 5 | クロスプラットフォーム設計の前提整理 | 長期 M5 の入力 |
| 短期 | 6 | ドキュメント参照リンクの自動チェック | M1 残タスク |
| 中期 | 1 | M2 Mise / Chezmoi 移行 | 進行中 |
| 中期 | 2 | M3 Chezmoi 機能の標準化 | M2 完了後 |
| 中期 | 3 | M4 品質・セキュリティ監査 | 継続 / M3 と並行可 |
| 中期 | 4 | M6 Mise 最適化と軽量化 | M2 完了後 |
| 中期 | 5 | M7 Kali Linux 対応 (Docker / VM RDP) | M6 と並行可。短期 1 / 2 が前提 |
| 長期 | 1 | M5 Windows / WSL と汎用化 | 短期5 の設計を踏襲 |

## 短期目標

- [ ] Ubuntu 26.04 の hosted runner / VM / LXD 環境を安定化し、`make init`、Chezmoi apply、Mise bootstrap の再現性を確認する
- [ ] Ubuntu slim / minimal profile の責務を整理し、CLI-only image と GUI profile の package・service 境界を明確化する
- [ ] hostname → profile (`desktop` / `minimal` / `darwin`) の対応表を `.chezmoidata` に置き、`linux.gui` package と Linux GUI script を desktop のみに限定する。`101` は本 Mac、未登録 hostname は fail-closed (または minimal)。Ubuntu の hostname 行は運用者が埋めるまで空欄
- [ ] GitHub 既定アカウントを `budybye` にし (source 管理の gh `hosts.yml` の `user:` を含む)、`boborder` は `gh auth switch` で切り替える。それ以外のアカウントは repo の既定・docs に載せない。path-based `includeIf` は採用しない
- [ ] cloud-init の共通処理、待機条件、ログ出力、冪等性を最適化し、Ubuntu / LXD / ARM64 の初期化時間と失敗率を下げる
- [ ] Obsidian vault を git 管理に組み込み、chezmoi / dotfiles リポジトリとの同期境界と運用方針を定義する
- [ ] macOS / Ubuntu / Windows / WSL / Docker を通したクロスプラットフォーム設計の前提と profile 境界を整理する
- [ ] 参照リンクと実ファイル構成の定期チェックを自動化(M1 残タスク)

## 中期目標

### M1: ドキュメントと正本の整理(完了)

- [x] README にドキュメント索引と正本パスを統合
- [x] 設計書を `docs/architecture.md` に統一
- [x] `docs/test.md` を追加（現 `docs/testing.md`）
- [x] `docs/tasks.md` の運用を `ROADMAP.md` に移行
- [x] Superpowers の2つの計画を README、docs、ROADMAP に統合

### M2: Mise / Chezmoi 移行

- [ ] package bootstrap の正本を Mise に集約
  - [ ] `install.sh` が `chezmoi init --apply` の前に Mise を導入する唯一の入口になる (他 script の Mise install、`packages.yaml` の mise curl 行は削除)
  - [ ] `packages.yaml` と `mise.toml` `[bootstrap.packages]` の package parity 表を作り、必要 package が正本ちょうど1行に存在することを確認する
  - [ ] Linux bootstrap を CLI と GUI (xfce4, xrdp, pipewire 等) に分離し、headless CI で desktop stack を入れない
  - [ ] cursor / coderabbit / zed の curl installer を冪等な Mise task へ移し、`packages.yaml` の `curl:` を削除する
  - [ ] Docker CE apt repo 導入を Mise task 化し、`act` の curl 経路を `mise/config.toml` に一本化する
- [ ] 重複する Chezmoi install script を段階的に縮退
  - [ ] 縮退は parity 表と CLI/GUI 分離の完了後、baseline 監査 (M4) と security review の後に行う (darwin bootstrap / linux cli・gui script は早期 exit guard から)
  - [ ] テンプレートが参照しなくなってから `packages.yaml` を `extensions` / `agents.skills` / `snap` (と Windows) のみに縮める。snap は Chezmoi に残す
- [ ] macOS defaults と platform profile の責務を整理 (Mise `[bootstrap.macos.*]` への移行は完了、残りは platform profile)
- [ ] `make` 互換入口を維持したまま Mise task を追加
  - [ ] root `.mise.toml` に `setup` / `install` / `apply` / `bootstrap:*` / `post-apply` / docker / vm task を置き、Makefile は Mise へ委譲する薄い wrapper にする (CI の `make init` を維持)
- [ ] ssh_setup を明示実行のみ・非破壊に保つ (`chezmoi apply` で SSH 鍵を生成・置換しない。新規生成は `ssh_setup --generate`)
- [ ] Mise runtime age と Chezmoi passphrase の鍵を分離したまま、Mise `[env]` による runtime secret を有効化する (有効化前に security.md へ鍵の分離を記録)

### M3: Chezmoi 機能の標準化

- [ ] template、`.chezmoiignore`、`.chezmoidata` の利用規則を統一
  - [ ] OS / distro / host / CI / container / sandbox の正規化 context と feature boolean を `.chezmoi.toml.tmpl` と `.chezmoidata/` に集約する。OS 判定は `.chezmoi.os` / `.chezmoi.osRelease`、hostname は意図的な差分のみ、username は主判定に使わない
  - [ ] 複数 target で共有する内容は `.chezmoitemplates` に置く
  - [ ] generated / cache / host-local / secret 由来のファイルを `.chezmoiignore` で通常管理から分離する
- [ ] lifecycle script の順序、冪等性、fail-closed 条件を検証
  - [ ] file attribute (`private_` / `executable_` / `once_` / `onchange_` / `before_` / `after_` 等) を `chattr` で監査・正規化する
  - [ ] script は prerequisite を確認し、反復実行しても安全で、実失敗時は非 0 で終了する。1 script group ずつ移行する
- [ ] secrets、external resource、generated file の境界を明文化
  - [ ] age / Bitwarden branch は CI・container・sandbox では無効化し、実ホストで secret 不足なら placeholder を書かずに明示エラーにする
  - [ ] `.chezmoiexternal.toml` は version / exact ref を固定し、refresh 失敗時は既存 resource を保持する
- [ ] macOS、Ubuntu、container の代表環境で apply / rollback を確認 (rollback は source revision の revert → 直前の正常 revision で再 apply。target の削除は diff を確認してから)
- [ ] `make check` / `make test` / `make verify` で template・script・attribute・platform の失敗を skip せず可視化する (`chezmoi data` / `diff` / `managed` / `ignored` / `execute-template` / `apply --dry-run` / `verify`)。ネットワーク依存の external 検証は高速な構文・template 検査から分離する

### M4: 継続的な品質・セキュリティ監査

- [ ] template、script、attribute、platform branch の CI 検証を強化
- [ ] secrets と supply chain の baseline / post-change review を実施
- [ ] package parity と duplicate authority を定期監査
- [ ] 大規模な script 縮退 (M2) の前に baseline 監査 (inventory・secret posture・script risk) を実施し、縮退後に security review を再実施する
- [ ] CI failure policy と recovery 手順を更新

### M6: Mise 最適化と軽量化

- [ ] Mise を tool version、package bootstrap、defaults、task orchestration の正本として整理する
- [ ] Chezmoi lifecycle script と Mise task の重複を削減し、初期化時間と実行回数を減らす
- [ ] CLI-only / GUI / Docker の最小構成を分離し、不要な GUI package と外部依存を入れない
- [ ] CI、Docker、WSL のキャッシュと並列実行を最適化し、再現性を維持したまま実行時間を短縮する
- [ ] package parity、生成物、キャッシュ容量を定期測定し、軽量化の効果を検証する

### M7: Kali Linux 対応 (Docker / VM RDP)

- [ ] Docker: Kali GUI image を追加し、xrdp + XFCE セッションを Ubuntu Full image と共通化する
- [ ] VM: Kali cloud-init を LXD 経路で追加する (multipass は Ubuntu 専用、OrbStack machine は Ubuntu / Debian 専用のため Kali は LXD のみ。image は `images:kali/current/cloud` — `current` エイリアスは cloud-init 無しの `default` variant を解決するため `cloud-init status --wait` が破綻する)
- [ ] chezmoi template の OS 分岐に kali (`os_release.id`) を追加し、未知環境は fail-closed を維持する
- [ ] CI: test.yaml に Kali LXD ジョブ、Docker build 検証に Kali image を追加する
- [ ] docs (tech.md, requirements.md, testing.md) に Kali の位置づけを記録する

## 長期目標

### M5: Windows / WSL と汎用化

- [ ] Windows native の Chezmoi apply と package bootstrap を安定化する
- [ ] WSL2 を Linux CLI profile として検証し、Windows native との差分を文書化する
- [ ] macOS、Ubuntu、Windows、WSL、Docker で共有できる profile / feature 境界を整理する
- [ ] ユーザー名・ホスト名・OS 固有分岐を減らし、未知の環境でも安全に fail-closed する

## リリース方針

- バージョンの正本は SemVer の git tag
- `tag.yaml` は test 成功後に release と tag を作成する
- `push.yaml` は tag を対象に GHCR image を公開する
- `latest` はリリース済み image の alias として扱う
- main push だけではリリース image を公開しない

## 更新ルール

1. 目標やマイルストーンを変更したら、このファイルを更新する
2. 実装手順やチェック項目はこのファイルに記録する
3. 完了条件は `docs/testing.md` と対応する workflow / command にリンクする
4. 技術の採用可否は `docs/tech.md` と実設定ファイルを更新してから記録する

## 関連ドキュメント

- [README](README.md)
- [要件定義](docs/requirements.md)
- [アーキテクチャ](docs/architecture.md)
- [検証ガイド](docs/testing.md)
- [技術スタック](docs/tech.md)
- [セキュリティ](docs/security.md)
- [ドキュメント](docs/)
