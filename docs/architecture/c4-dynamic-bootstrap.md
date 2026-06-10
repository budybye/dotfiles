# C4 — Dynamic: 初回ブートストラップ

**用途:** 新しいマシンでシークレット準備からパッケージ導入までの典型フロー。

## 図

```mermaid
C4Dynamic
  title Dynamic Diagram for First-run Bootstrap

  Person(owner, "Machine owner", "新端末セットアップ")
  Container(cli, "Chezmoi CLI", "chezmoi", "init / apply")
  Container(src, "Source tree", "Git", "home/ + scripts")
  Container(ageScript, "run_once_before_age", "Bash tmpl", "key.txt 復号")
  Container(bwScript, "run_once_before_bw", "Bash tmpl", "BW 連携準備")
  Container(pkgScripts, "OS bootstrap scripts", "darwin/linux/windows", "packages.yaml 適用")
  ContainerDb(home, "Home & XDG", "FS", "~/.config/chezmoi 等")
  Container_Ext(bw, "Bitwarden CLI", "bw", "vault（任意）")

  Rel(owner, cli, "1. make init / chezmoi init --apply", "shell")
  Rel(cli, src, "2. ソース取得・テンプレ読取", "Git / read")
  Rel(cli, ageScript, "3. before: age 準備", "exec")
  Rel(ageScript, home, "4. key.txt を配置", "chmod 600")
  Rel(cli, bwScript, "5. before: BW 準備", "exec")
  Rel(bwScript, bw, "6. 必要なら unlock / 参照", "CLI")
  Rel(cli, home, "7. 設定・暗号化資産を展開", "write")
  Rel(cli, pkgScripts, "8. after/onchange: パッケージ導入", "exec")
```

## 補足

- CI / Docker / 一部ユーザーでは `.chezmoi.toml.tmpl` により **age / Bitwarden が無効**（[security.md](../security.md)）。
- macOS は `darwin/run_onchange_after_bootstrap.sh.tmpl`、Linux は `linux/run_onchange_after_cli.sh.tmpl` 等がパッケージ導入の中心。
- `make bw-unlock` は適用前に vault を開く補助コマンド。
