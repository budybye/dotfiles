# C4 — Dynamic: `chezmoi apply` 周り

**用途:** ローカルで「ソース → ホーム反映」がどう流れるかを番号付きで追う。

## 図

```mermaid
C4Dynamic
  title Dynamic — Typical apply / refresh flow

  Person(owner, "Machine owner", "ローカル操作")
  Container(src, "Source tree", "Git", "home/*.tmpl, run_* 等")
  Container(cli, "Chezmoi CLI", "chezmoi", "apply / re-add / diff")
  ContainerDb(home, "Home layout", "FS", "展開先パス")

  Rel(owner, cli, "1. chezmoi apply / diff", "shell")
  Rel(cli, src, "2. テンプレ評価・run_* 条件実行", "read")
  Rel(cli, home, "3. ファイル書込・権限反映", "write")
  Rel(owner, src, "4. （必要なら）chezmoi re-add で逆同期", "Git / chezmoi")
```

## 補足

- 実際の分岐（OS テンプレ、encrypted、`run_once_*`）は [design.md](../design.md) や chezmoi 本体の手順に従う。
- **エージェント向け:** 変更後の検証は `git diff` / `jj diff` や `make check`（方針は [AGENTS.md](../../AGENTS.md)）。
