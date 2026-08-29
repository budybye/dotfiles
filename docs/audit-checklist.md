---
name: audit-checklist
description: dotfiles 監査チェックリスト
---

# Dotfiles 監査チェックリスト

OpenSpec: tasks §10。ゲート: **§5 retire 前**に baseline 必須。

## チェック（要約）

1. chezmoi managed/unmanaged/ignored
2. CI/Docker で chezmoi data — secrets off
3. .chezmoiscripts owner 表
4. encrypted_* 一覧
5. パッケージ parity（正本1行）
6. 二重 apply 冪等性
7. chezmoi verify
8. externals ピン留め

成果物: audit-report-YYYY-MM.md
