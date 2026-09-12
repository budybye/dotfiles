---
name: roadmap
description: プロジェクトの目標・進捗・バージョン計画
---

# Roadmap - Chezmoi Dotfiles

## 目的

このファイルは、プロジェクトの中長期目標、到達点、進行中の作業、リリース方針を管理します。

README.md と docs/ が運用・設計の正本です。詳細な変更計画は必要な場合だけローカルで管理します。

個別の実装手順はこのファイルに重複させず、必要に応じてローカルの計画ファイルに置きます。

## 現在地

- Chezmoi がテンプレート、設定、暗号化ファイル、OS・host 分岐を管理する
- Mise がツール、package bootstrap、macOS defaults の正本へ移行中
- Makefile は既存利用者と CI の互換入口として維持する
- GitHub Actions は複数 OS、Docker、LXD、arm64 環境を検証する
- SemVer git tag がリリースバージョンの単一ソースである

## 短期目標

- [ ] Ubuntu 26.04 の hosted runner / VM / LXD 環境を安定化し、`make init`、Chezmoi apply、Mise bootstrap の再現性を確認する
- [ ] Ubuntu slim / minimal profile の責務を整理し、CLI-only image と GUI profile の package・service 境界を明確化する
- [ ] cloud-init の共通処理、待機条件、ログ出力、冪等性を最適化し、Ubuntu / LXD / ARM64 の初期化時間と失敗率を下げる

## マイルストーン

### M1: ドキュメントと正本の整理

- [x] README にドキュメント索引と正本パスを統合
- [x] 設計書を `docs/architecture.md` に統一
- [x] `docs/test.md` を追加
- [x] `docs/tasks.md` の運用を `ROADMAP.md` に移行
- [x] Superpowers の2つの計画を README、docs、ROADMAP に統合
- [ ] 参照リンクと実ファイル構成の定期チェックを自動化

### M2: Mise / Chezmoi 移行

- [ ] package bootstrap の正本を Mise に集約
- [ ] 重複する Chezmoi install script を段階的に縮退
- [ ] macOS defaults と platform profile の責務を整理
- [ ] `make` 互換入口を維持したまま Mise task を追加

### M3: Chezmoi 機能の標準化

- [ ] template、`.chezmoiignore`、`.chezmoidata` の利用規則を統一
- [ ] lifecycle script の順序、冪等性、fail-closed 条件を検証
- [ ] secrets、external resource、generated file の境界を明文化
- [ ] macOS、Ubuntu、container の代表環境で apply / rollback を確認

### M4: 継続的な品質・セキュリティ監査

- [ ] template、script、attribute、platform branch の CI 検証を強化
- [ ] secrets と supply chain の baseline / post-change review を実施
- [ ] package parity と duplicate authority を定期監査
- [ ] CI failure policy と recovery 手順を更新

### M5: Windows / WSL と汎用化

- [ ] Windows native の Chezmoi apply と package bootstrap を安定化する
- [ ] WSL2 を Linux CLI profile として検証し、Windows native との差分を文書化する
- [ ] macOS、Ubuntu、Windows、WSL、Docker で共有できる profile / feature 境界を整理する
- [ ] ユーザー名・ホスト名・OS 固有分岐を減らし、未知の環境でも安全に fail-closed する

### M6: Mise 最適化と軽量化

- [ ] Mise を tool version、package bootstrap、defaults、task orchestration の正本として整理する
- [ ] Chezmoi lifecycle script と Mise task の重複を削減し、初期化時間と実行回数を減らす
- [ ] CLI-only / GUI / Docker の最小構成を分離し、不要な GUI package と外部依存を入れない
- [ ] CI、Docker、WSL のキャッシュと並列実行を最適化し、再現性を維持したまま実行時間を短縮する
- [ ] package parity、生成物、キャッシュ容量を定期測定し、軽量化の効果を検証する

## 詳細な変更計画

詳細な変更計画は、必要な場合だけローカルで管理します。計画ファイルはGitHubへ公開せず、README、docs、ROADMAPだけで通常運用を完結させます。

## リリース方針

- バージョンの正本は SemVer の git tag
- `tag.yaml` は test 成功後に release と tag を作成する
- `push.yaml` は tag を対象に GHCR image を公開する
- `latest` はリリース済み image の alias として扱う
- main push だけではリリース image を公開しない

## 更新ルール

1. 目標やマイルストーンを変更したら、このファイルを更新する
2. 実装手順やチェック項目はまずこのファイルに記録し、必要な場合だけローカルの計画ファイルへ展開する
3. 完了条件は `docs/test.md` と対応する workflow / command にリンクする
4. 技術の採用可否は `docs/tech.md` と実設定ファイルを更新してから記録する
5. ローカルの計画ファイルを使った場合も、完了条件はこのファイルと正本ドキュメントへ反映する

## 関連ドキュメント

- [README](README.md)
- [要件定義](docs/requirements.md)
- [アーキテクチャ](docs/architecture.md)
- [検証ガイド](docs/test.md)
- [技術スタック](docs/tech.md)
- [セキュリティ](docs/security.md)
- [ドキュメント](docs/)
