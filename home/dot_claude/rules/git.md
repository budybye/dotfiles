# Git / VCS Workflow

## Commit Message Format

```
<type>: <description>

<optional body>
```

**Types**: feat, fix, refactor, docs, test, chore, perf, ci

- 件名は命令形、50文字以内
- 本文は「なぜ」を説明する（「何を」は diff で分かる）

## Branch Strategy

- `main` / `master` への直接 push は避ける
- feature branch は短命に保つ（1-3日）
- マージ前に rebase で履歴を整理する

## PR Workflow

1. `git diff [base-branch]...HEAD` で全変更を確認
2. commit 履歴全体を分析してPRサマリーを作成
3. テストプランを含める
4. 新規ブランチは `-u` フラグで push

## jj (Jujutsu) 使用時

- `jj new` で新しい変更を開始
- `jj describe` でコミットメッセージを記述
- `jj squash` で変更をまとめる
- colocated repo (`jj git init --colocate`) では git 操作も可能
- 詳細は `/jj-vcs` スキルを参照

## Safety

- `--force` push は原則禁止（`--force-with-lease` を使う）
- `.env`, credentials, secrets を絶対にコミットしない
- 大きなバイナリは Git LFS を使う
