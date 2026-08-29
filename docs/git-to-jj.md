---
name: git-to-jj
description: Git から Jujutsu (jj) への移行ガイド — この dotfiles リポジトリ向け
---

# Git → Jujutsu (jj) 移行ガイド

このドキュメントは、日常の VCS 操作を **git から jj (Jujutsu) へ段階的に移す**ための手順と、このリポジトリ固有の設定をまとめたものです。

**方針:** jj を主 VCS にしつつ、**colocated モード**で git リモート・CI・協作者との互換を維持する。git を完全にアンインストールする必要はありません。

---

## このリポジトリで既にあるもの

| 資産 | パス | 役割 |
|------|------|------|
| `jjj` | `home/dot_local/bin/executable_jjj` | describe → new → bookmark set → `jj git push` のワンショット |
| `jjui` | `mise/config.toml` `[tools]` | jj 用 TUI |
| `jj-stack` / `jj-ryu` | `mise/config.toml` `npm:*` | jj ワークフロー補助 CLI |
| Claude ルール | `home/private_dot_config/claude/rules/git.md` | コミット規約 + jj 節 |
| Makefile | `git-commit` / `git-status` | **まだ git 直叩き**（移行対象） |
| AGENTS.md | Verify 節 | `git diff` または `jj diff` |

**ギャップ:** `jj` 本体は `mise/config.toml` に未登録（OS パッケージ or 手動インストール想定）。移行の第一歩は `jj = "latest"` を `[tools]` に追加すること。

---

## なぜ colocated か

```bash
# 既存 git リポジトリを colocate 化（推奨）
cd /path/to/repo
jj git init --colocate
```

| モード | `.git` | jj 操作 | git 操作 | 用途 |
|--------|--------|---------|----------|------|
| **colocated** | 残る | ✅ | ✅（読み取り・fetch 中心） | 既存 GitHub リモート、CI、PR |
| **jj-only** | なし | ✅ | `jj git` 経由のみ | 新規・実験用 |

colocated では GitHub 上のブランチ・PR・Actions は **git 互換のまま**動き、ローカル作業は jj の変更（change）モデルで行えます。

---

## 移行チェックリスト

### 1. ツール導入

```bash
# mise 管理（推奨 — config.toml に追加後）
mise use -g jj@latest
mise install

# または OS パッケージ（mise.toml [bootstrap.packages] へ移行予定）
# brew install jj    # macOS
# apt install jujutsu  # Ubuntu (要確認)
```

`~/.config/jj/config.toml` は chezmoi で管理するか、グローバル設定として手動維持するかを決める（現状はリポジトリ未管理）。

### 2. 既存リポジトリを colocate 化

```bash
cd ~/.local/share/chezmoi   # この dotfiles ソース例
jj git init --colocate
jj status
jj log -n 5
```

**注意:** すでに `.git` があるディレクトリでのみ実行。bare リポジトリは `jj git clone --colocate <url>` を検討。

### 3. ユーザー設定（最小）

`~/.config/jj/config.toml` の例:

```toml
[user]
name = "Your Name"
email = "you@example.com"

[ui]
default-command = "log"
paginate = "auto"

[git]
auto-local-bookmark = true   # 必要に応じて
```

chezmoi の `[data].identity`（Phase 4 の `host_profiles.yaml`）と名前・メールを揃える。

### 4. 日常フローを jj に切り替え

| やりたいこと | git（旧） | jj（新） |
|--------------|-----------|----------|
| 状態確認 | `git status` | `jj status` / `jj st` |
| 差分 | `git diff` | `jj diff` |
| 変更を記録 | `git add` + `git commit` | `jj describe -m "msg"` → `jj new` |
| 新しい作業開始 | `git checkout -b feat` | `jj new`（ブランチ不要） |
| 履歴 | `git log` | `jj log` |
| リモート同期 | `git pull` / `push` | `jj git fetch` / `jj git push` |
| ブックマーク（≈ブランチ） | `git branch` | `jj bookmark list` |
| まとめる | `git rebase -i` | `jj squash` / `jj rebase` |
| 取り消し | `git reset` | `jj undo` / `jj restore` |

### 5. このリポジトリの `jjj` を使う

```bash
# メッセージ + 現在のブックマークへ push（git symbolic-ref / trunk 自動検出）
jjj "feat: add jj guide"

# ブックマーク明示
jjj "fix: typo" my-feature

# リモート明示
jjj "chore: bump" main origin
```

`jjj` の挙動:

1. `jj git import` — git 側の stale index を解消
2. ブックマーク自動検出（`git` の HEAD → `main`/`master`/`trunk` → 祖先上の非 `_reserve/*`）
3. `jj describe` → `jj new` → `jj bookmark set` → `jj git push`

**`_reserve/*` ブックマーク**は change-id 予約用。`jjj` はこれを進めません。

### 6. Makefile / mise task の移行（計画）

| 現状 | 移行先 |
|------|--------|
| `make git-commit` | `mise run vcs:push` または `jjj` ラッパー |
| `make git-status` | `mise run vcs:status` → `jj st` |
| `git describe`（Makefile バージョン） | そのまま（タグは git 互換） |

CI（`.github/workflows/`）は **当面 git のまま**。`actions/checkout` は colocated リポジトリでも `.git` を読むため変更不要。

---

## git を残す場面（完全置換しない）

| 場面 | 理由 |
|------|------|
| GitHub PR / Actions | リモートは git プロトコル |
| `chezmoi init <git-url>` | chezmoi のソース取得 |
| `git clone` / `git submodule` | 第三者ツール・ドキュメント |
| `make` の `DOTFILES_VERSION` | `git describe --tags` |
| 協作者が git のみ | colocated なら双方共存 |

**目標:** 人間の手作業は jj、インフラ・リモート境界は git 互換 — というハイブリッド。

---

## よくあるトラブル

| 症状 | 対処 |
|------|------|
| `jj: not a jj repository` | `jj git init --colocate` を実行 |
| git と jj の状態がずれる | `jj git import`（`jjj` も先頭で実行） |
| push 先ブックマークがわからない | `jj bookmark list` / `jjj` に第2引数で明示 |
| `_reserve/foo` が動かない | 意図的 — 予約用ブックマーク |
| `lazygit` が jj 非対応 | `jjui` または `jj log` / `jj op` を使用 |

---

## mise / chezmoi との関係

```text
mise install jj          # CLI バージョン管理
chezmoi apply            # jjj スクリプト、claude/rules/git.md を配置
jj git init --colocate   # 各ワークスペースで一度だけ
jjj "msg"                # 日常の commit+push
```

Phase 4 のドキュメント拡充（`docs/bootstrap.md`, `docs/platform-matrix.md`）と並行して、VCS 節を `platform-matrix.md` に追加予定。

---

## 参照リンク

- [Jujutsu 公式](https://jj-vcs.dev/)
- [Git compatibility](https://jj-vcs.dev/latest/git-compatibility/)
- [Colocated repos](https://jj-vcs.dev/latest/git-compatibility/#colocated-jujutsurepos)
- [Command comparison](https://jj-vcs.dev/latest/git-command-table/)
- このリポジトリ: `home/dot_local/bin/executable_jjj`, `home/private_dot_config/claude/rules/git.md`

---

## 次の実装タスク（OpenSpec）

1. `mise/config.toml` に `jj = "latest"` を追加
2. `.mise.toml` に `vcs:status` / `vcs:push`（`jjj` 委譲）タスク
3. `Makefile` の `git-commit` / `git-status` を mise 委譲
4. （任意）`~/.config/jj/config.toml` を chezmoi 管理化

詳細は `openspec/changes/chezmoi-to-mise-migration/tasks.md` §9.8 を参照。
