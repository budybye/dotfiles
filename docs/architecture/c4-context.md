# C4 — System Context (Level 1)

**System:** Chezmoi で管理する個人 dotfiles（macOS / Ubuntu、XDG 準拠）。  
**Audience:** 新規メンバー・未来の自分・エージェント向けの境界確認。

## 図

```mermaid
C4Context
  title System Context — Personal dotfiles (Chezmoi)

  Person(owner, "Machine owner", "編集・適用・新端末セットアップを行う")
  Person_Ext(agent, "Coding agent", "AGENTS.md / docs に沿って変更を提案する場合あり")

  System(dotfiles, "Personal dotfiles", "Chezmoi テンプレートと home/ 下の設定を Git で管理")
  System_Ext(gitRemote, "Git hosting", "リモート上のソースオブトゥルース（履歴・共有）")
  System_Ext(hostOS, "Host OS", "macOS / Ubuntu 等。$HOME と OS パッケージ層を提供")
  System_Ext(toolchain, "Secrets & crypto", "age / SSH / Bitwarden など（リポ方針は docs/security.md）")
  System_Ext(gha, "GitHub Actions", "テスト・タグ・コンテナイメージ等の CI（.github/workflows）")

  Rel(owner, dotfiles, "編集・commit・chezmoi apply")
  Rel(agent, dotfiles, "差分提案（スコープ内）")
  Rel(dotfiles, gitRemote, "push / pull / clone")
  Rel(dotfiles, hostOS, "設定をテンプレ展開して $HOME 等へ反映")
  Rel(dotfiles, toolchain, "暗号化テンプレ・鍵運用パターンに依存")
  Rel(gha, gitRemote, "リポジトリをトリガに実行")
```

## 読み方

- **ソフトウェアシステム**は「Git で持つ dotfiles 一式＋それを適用する運用」のまとまりとして扱っている（実行ファイルは chezmoi / ホストが担う）。
- **外部**は「ホスト」「リモート Git」「シークレット系」「CI」に分け、責務の擦れを減らす。

詳細な配置ルールは [directory.md](../directory.md)、スタックは [tech.md](../tech.md)。
