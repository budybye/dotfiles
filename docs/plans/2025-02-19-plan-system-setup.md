# Plan System Setup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** dotfiles プロジェクトに実行可能な実装計画システムを導入し、AI エージェントと人間の両方が一貫した手順で機能を実装できるようにする。

**Architecture:** docs/plan.md を計画の索引として拡充し、docs/plans/ に日付付きの詳細計画を配置。各計画は bite-sized タスクで構成し、File/Step/Commit を明示。dotfiles の検証は `chezmoi diff` と `make check` および GitHub Actions を用いる。

**Tech Stack:** Chezmoi, Markdown, GitHub Actions, Makefile

**Reference:** [docs/requirements.md](../requirements.md), [docs/design.md](../design.md), [AGENTS.md](../../AGENTS.md)

---

## Status: 完了 (Reference Implementation)

この計画は計画システム自体のセットアップを定義する。以下の成果物が作成済み。

### 成果物一覧

| ファイル                                     | 役割                           |
| -------------------------------------------- | ------------------------------ |
| `docs/plan.md`                               | 計画索引・実行ガイド・検証方法 |
| `docs/plans/TEMPLATE.md`                     | 新規計画のひな型               |
| `docs/plans/2025-02-19-plan-system-setup.md` | 本計画（参照用）               |
| `docs/plans/2025-02-19-wsl2-support.md`      | WSL2 対応計画（実装待ち）      |

### 実行済みタスク（参考）

#### Task 1: docs/plans ディレクトリ作成

**Files:** Create: `docs/plans/`

**Step 1:** ディレクトリ作成

```bash
mkdir -p docs/plans
```

**Step 2:** 確認

```bash
ls -la docs/plans/
```

#### Task 2: docs/plan.md 拡充

**Files:** Modify: `docs/plan.md`

**Step 1:** 既存の空 frontmatter を保持しつつ本文を追加
**Step 2:** 計画配置、構成要素、検証方法、既存計画一覧を記載
**Step 3:** 関連ドキュメントへのリンクを追加

#### Task 3: TEMPLATE.md 作成

**Files:** Create: `docs/plans/TEMPLATE.md`

**Step 1:** writing-plans スキル形式に dotfiles 向け調整
**Step 2:** 検証方法を chezmoi diff / make check に合わせる

---

## 今後の計画作成手順

1. `docs/plans/TEMPLATE.md` をコピー
2. ファイル名を `YYYY-MM-DD-<feature-name>.md` にリネーム
3. Goal, Architecture, Tech Stack を具体化
4. タスクを bite-sized（2-5分）で分割
5. 各タスクに Files / Step 1-5 / Commit を記載
6. `docs/plan.md` の既存計画一覧に追加
