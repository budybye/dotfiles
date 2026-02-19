---
name: plan
description: 計画書 レビュー要件 非機能要件 実装計画の索引と実行ガイド
---

# 計画書 - Chezmoi Dotfiles Management System

## 概要

このドキュメントは、プロジェクトの実装計画システムの索引と実行ガイドです。各機能の詳細な実装計画は [`docs/plans/`](./plans/) に配置され、タスク単位で実行可能な形式で記載されています。

## 実装計画の配置

| 形式             | パス                           | 説明                             |
| ---------------- | ------------------------------ | -------------------------------- |
| 計画一覧         | `docs/plans/`                  | 日付付きの実装計画ファイル       |
| 計画テンプレート | `docs/plans/TEMPLATE.md`       | 新規計画作成時のひな型           |
| 計画命名規則     | `YYYY-MM-DD-<feature-name>.md` | 例: `2025-02-19-wsl2-support.md` |

## 計画の構成要素

各実装計画は以下の構成に従います。詳細は [writing-plans スキル](https://github.com/budybye/dotfiles/blob/main/.cursor/skills/writing-plans/SKILL.md) を参照してください。

### 必須ヘッダー

```markdown
# [機能名] Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** [一言で目的を説明]
**Architecture:** [2-3文のアプローチ概要]
**Tech Stack:** [主要技術・ライブラリ]

---
```

### タスク構造（dotfiles 向け）

- **Files:** 作成・修正するファイルの正確なパス
- **Step 1:** 失敗する検証を書く（`make check` や `chezmoi diff`）
- **Step 2:** 検証を実行して失敗を確認
- **Step 3:** 最小限の実装
- **Step 4:** 検証を実行して成功を確認
- **Step 5:** コミット（conventional commits）

### 検証方法（このプロジェクト）

| 検証種別     | コマンド                      | 用途                       |
| ------------ | ----------------------------- | -------------------------- |
| 設定差分確認 | `chezmoi diff`                | 意図しない変更の検出       |
| 構成チェック | `make check`                  | 設定の妥当性確認           |
| CI 実行      | `.github/workflows/test.yaml` | クロスプラットフォーム動作 |
| 手動検証     | 対象 OS での `make init`      | 実際のセットアップ確認     |

## 既存計画一覧

| 計画                                                         | 目的                   | ステータス |
| ------------------------------------------------------------ | ---------------------- | ---------- |
| [Plan System Setup](./plans/2025-02-19-plan-system-setup.md) | 計画システムの基盤整備 | 参照用     |
| [WSL2 Support](./plans/2025-02-19-wsl2-support.md)           | WSL2 完全対応          | 未着手     |

## 関連ドキュメント

- [要件定義](./requirements.md) - 機能・非機能要件
- [設計書](./design.md) - アーキテクチャ・設計方針
- [タスク管理](./tasks.md) - タスクカテゴリ・優先度
- [技術スタック](./tech.md) - 使用技術・パッケージ管理
- [ディレクトリ構成](./directory.md) - ファイル配置設計
- [環境差の注意点](./problems.md) - プラットフォーム差・ライブラリの癖

## 実行オプション

計画実行時に以下のいずれかを選択できます：

1. **Subagent-Driven（このセッション）** - タスクごとにサブエージェントを起動し、タスク間でレビュー
2. **Parallel Session（別セッション）** - 新規セッションで executing-plans を使用し、チェックポイント付きで一括実行

## AGENTS.md との整合

実装時は [AGENTS.md](../AGENTS.md) の以下を遵守してください：

- 明示的に指示されていない変更は行わない
- 技術スタックのバージョンは承認なく変更しない
- YAGNI / DRY / KISS のコーディング原則
- 日本語でのコメント・説明
