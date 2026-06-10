# C4 — Dynamic: `chezmoi apply`

**用途:** ローカルで「ソース → ホーム反映」がどう流れるかを番号付きで追う。

## 図

```mermaid
C4Dynamic
  title Dynamic Diagram for chezmoi apply

  Person(owner, "Machine owner", "ローカル操作")
  Container(cli, "Chezmoi CLI", "chezmoi", "apply / diff / data")
  Container(src, "Source tree", "Git", "home/*.tmpl, run_*, packages.yaml")
  Container(scripts, "Bootstrap scripts", "Bash", "run_once_* / run_onchange_*")
  ContainerDb(home, "Home layout", "FS", "展開先パス")
  Container_Ext(secrets, "age / Bitwarden", "CLI", "復号・テンプレ変数")

  Rel(owner, cli, "1. chezmoi apply / make apply", "shell")
  Rel(cli, src, "2. テンプレ評価・ignore 判定", "read")
  Rel(cli, secrets, "3. 必要なら age 復号 / BW 参照", "CLI")
  Rel(cli, home, "4. ファイル書込・権限反映", "write")
  Rel(cli, scripts, "5. 条件付きで run_* 実行", "exec")
  Rel(scripts, home, "6. パッケージ導入・後処理", "OS pkg / mise")
  Rel(owner, src, "7. 必要なら re-add で逆同期", "chezmoi / Git")
```

## 補足

- 分岐（OS テンプレ、encrypted、`run_once_*`、CI/Docker での age 無効化）は [design.md](../design.md) / [security.md](../security.md) に従う。
- 初回ブートストラップ（age → BW → パッケージ）は [c4-dynamic-bootstrap.md](./c4-dynamic-bootstrap.md)。
- 変更後の検証は `git diff` / `jj diff` や `make check`（[AGENTS.md](../../AGENTS.md)）。
