# WSL2 Support Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** WSL2 (Ubuntu 24.04) 上で `make init` が成功し、GitHub Actions の WSL2 ジョブが有効化される。

**Architecture:** 既存の `.github/workflows/test.yaml` のコメントアウトされている wsl2 ジョブを有効化し、WSL2 内での chezmoi 実行に必要な前提条件（curl, git, make）を確保。必要に応じて `home/.chezmoi.toml.tmpl` や OS 判定ロジックに `wsl` 条件を追加する。

**Tech Stack:** Chezmoi, GitHub Actions, WSL2, Vampire/setup-wsl (or alternatives), Bash

**Reference:** [docs/requirements.md](../requirements.md) L50-54, [.github/workflows/test.yaml](../../.github/workflows/test.yaml) L104-117

---

## Prerequisites

- [ ] `make check` passes on main branch
- [ ] Windows runner で WSL2 が利用可能（GitHub-hosted: windows-2022 以降）
- [ ] Vampire/setup-wsl の最新版を確認

---

### Task 1: WSL2 ジョブの有効化と最小検証

**Files:**

- Modify: `.github/workflows/test.yaml:104-117`

**Step 1: 現在の WSL2 ジョブを確認**

```bash
# コメントアウト部分を確認
sed -n '104,117p' .github/workflows/test.yaml
```

**Step 2: ジョブを有効化（最小構成）**

```yaml
wsl2:
    runs-on: windows-2022
    steps:
        - uses: actions/checkout@v5
        - name: Setup WSL
          uses: Vampire/setup-wsl@v3
          with:
              distribution: Ubuntu-24.04
        - name: WSL2 dotfiles init
          shell: wsl-bash {0}
          run: |
              sudo apt-get update -y
              sudo apt-get install -y curl git make
              WORKSPACE="$(wslpath '${{ github.workspace }}')"
              cd "$WORKSPACE"
              make init
```

注: `install.sh` は `--source=${SCRIPT_DIR}` で repo を指定するため、repo ルートで `make init` を実行すればよい。

**Step 3: 実行コマンドの調整**

`install.sh` の内容を確認し、WSL2 上で実行可能か検証。
`make init` は `./install.sh` を呼ぶ。install.sh が curl/git で chezmoi を取得する想定なら、WSL に curl, git が入っている必要あり。
Ubuntu 24.04 の WSL イメージには通常含まれるが、明示的に `apt update && apt install -y curl git` を追加するか検討。

**Step 4: コミット**

```bash
git add .github/workflows/test.yaml
git commit -m "ci: enable WSL2 job for dotfiles init"
```

**Step 5: プッシュして CI 確認**

```bash
git push origin <branch>
# GitHub Actions で wsl2 ジョブの success/failure を確認
```

---

### Task 2: WSL2 用の OS 判定と設定分岐（必要に応じて）

**Files:**

- Modify: `home/.chezmoi.toml.tmpl`（WSL 固有の include/exclude がある場合）
- Verify: [docs/directory.md](../directory.md) L233 の WSL 列

**Step 1: WSL 環境の検出方法を確認**

Chezmoi のテンプレートで `{{ .chezmoi.os }}` は WSL2 上では `linux` となる。
WSL 固有の分岐が必要な場合は、`{{ .chezmoi.hostname }}` や環境変数 `WSL_DISTRO_NAME` の有無で判定するか、`~/.wslconfig` 等の存在で判定。

**Step 2: 分岐が不要な場合**

現状で Ubuntu 24.04 と同等の扱いで問題なければ、本タスクはスキップ可能。

**Step 3: 分岐が必要な場合**

```toml
# home/.chezmoi.toml.tmpl の例
{{ if or (eq .chezmoi.os "linux") (env "WSL_DISTRO_NAME") }}
# WSL/Linux 共通設定
{{ end }}
```

---

### Task 3: ドキュメント更新

**Files:**

- Modify: `docs/requirements.md:50`
- Modify: `README.md:12,65`
- Modify: `docs/plan.md:60`

**Step 1: requirements.md の WSL2 ステータス更新**

```markdown
- **WSL2**: Ubuntu 24.04 LTS - Windows Subsystem for Linux 2（CI 検証済み）
```

**Step 2: README の「追加予定」を「対応済み」に更新（CI 成功後）**

**Step 3: docs/plan.md の既存計画一覧のステータス更新**

```markdown
| [WSL2 Support](./plans/2025-02-19-wsl2-support.md) | WSL2 完全対応 | 完了 |
```

**Step 4: コミット**

```bash
git add docs/
git commit -m "docs: update WSL2 support status"
```

---

## 検証チェックリスト

- [ ] `make check` が main でパス
- [ ] GitHub Actions の wsl2 ジョブが success
- [ ] 実機の WSL2 (Ubuntu 24.04) で `make init` が成功（オプション）
- [ ] 既存ジョブ（ubuntu-amd64, darwin 等）に影響なし

## 既知の制約・注意点

- `Vampire/setup-wsl` のメンテナンス状況を定期的に確認
- Windows ランナーは macOS/Ubuntu よりスロット取得が遅い場合あり
- WSL2 内の Linux は `{{ .chezmoi.os }}` が `linux` のため、Ubuntu 専用設定との区別が必要な場合は別途ホスト名やファイル存在チェックを検討
