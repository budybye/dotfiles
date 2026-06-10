# C4 — Component: Source tree

**Scope:** `home/` を中心としたソースツリー内部の責務分割。  
**Audience:** 設定追加・テンプレ変更を行う開発者 / エージェント。

## 図

```mermaid
C4Component
  title Component Diagram for Dotfiles Source Tree

  Container_Ext(chezmoiCli, "Chezmoi CLI", "chezmoi", "apply / template / data")
  Container_Ext(homeFs, "Home & XDG", "POSIX FS", "展開先")

  Container_Boundary(src, "Source tree") {
    Component(tmplEngine, "Templates & ignore", "*.tmpl / .chezmoiignore", "OS・環境分岐と除外")
    Component(data, "Chezmoi data", ".chezmoidata", "packages.yaml 等のテンプレ変数")
    Component(secretsFiles, "Encrypted assets", "encrypted_*.age / key.txt.age", "SSH・env 等の機密")
    Component(xdgConfigs, "XDG configs", "private_dot_config/", "シェル・エディタ・ツール設定")
    Component(localBins, "User binaries", "dot_local/bin/", "executable_* ユーティリティ")
    Component(bootstrap, "Bootstrap scripts", ".chezmoiscripts/", "run_once_* / run_onchange_*")
  }

  Rel(chezmoiCli, tmplEngine, "テンプレ評価・除外判定")
  Rel(chezmoiCli, data, "変数を読込")
  Rel(tmplEngine, xdgConfigs, "条件付きで出力対象を決定")
  Rel(tmplEngine, localBins, "条件付きで出力対象を決定")
  Rel(chezmoiCli, secretsFiles, "age で復号して配置")
  Rel(chezmoiCli, bootstrap, "順序付きでスクリプト実行")
  Rel(bootstrap, data, "パッケージ一覧を参照")
  Rel(chezmoiCli, homeFs, "ファイル書込・権限反映")
```

## コンポーネントメモ

| コンポーネント | 主なパス | 役割 |
| --- | --- | --- |
| Templates & ignore | `*.tmpl`, `.chezmoiignore`, `.chezmoi.toml.tmpl` | OS / CI / Docker 分岐 |
| Chezmoi data | `home/.chezmoidata/packages.yaml` | brew/apt/snap/mise 等の宣言 |
| Encrypted assets | `home/dot_ssh/encrypted_*`, `encrypted_private_executable_envars.age` | 機密のリポ内保管 |
| XDG configs | `home/private_dot_config/` | 適用後は `~/.config` |
| Bootstrap scripts | `home/.chezmoiscripts/{darwin,linux,windows}/` | 初回・変更時のホスト準備 |

ファイル属性プレフィックス（`dot_` / `private_` / `encrypted_` 等）は [directory.md](../directory.md) を参照。
