# C4 — System Context (Level 1)

**System:** Chezmoi で管理する個人 dotfiles（macOS / Ubuntu、XDG 準拠）。  
**Audience:** 新規メンバー・未来の自分・エージェント向けの境界確認。

## 図

```mermaid
C4Context
  title System Context diagram for Personal Dotfiles

  Person(owner, "Machine owner", "編集・適用・新端末セットアップ")
  Person_Ext(agent, "Coding agent", "AGENTS.md / docs に沿って差分提案")

  System(dotfiles, "Personal Dotfiles", "Chezmoi テンプレと home/ を Git で管理しホストへ再現")

  System_Ext(gitHost, "GitHub", "ソース・Release・GHCR・Actions")
  System_Ext(hostOS, "Host OS", "macOS / Ubuntu。$HOME と OS パッケージ層")
  System_Ext(secrets, "Secrets toolchain", "age / Bitwarden / SSH")
  System_Ext(pkgMgr, "Package managers", "brew / apt / snap / mise / aqua")
  System_Ext(ipfs, "IPFS / Filebase", "main push 時のミラーピン")

  Rel(owner, dotfiles, "編集・commit・chezmoi apply / make init")
  Rel(agent, dotfiles, "スコープ内の差分提案")
  Rel(dotfiles, gitHost, "clone / push / pull / Release")
  Rel(dotfiles, hostOS, "設定をテンプレ展開して反映")
  Rel(dotfiles, secrets, "暗号化テンプレ・鍵運用に依存")
  Rel(dotfiles, pkgMgr, "bootstrap でツールを導入")
  Rel(gitHost, ipfs, "Actions 経由でピン")
```

## 読み方

- **ソフトウェアシステム**は「Git で持つ dotfiles 一式＋適用運用」のまとまり（実行は chezmoi / ホストが担う）。
- **外部**はホスト・GitHub・シークレット・パッケージマネージャ・IPFS に分け、責務の境界を明確にする。
- CI（GitHub Actions）は GitHub 側の能力として扱い、詳細は [c4-containers.md](./c4-containers.md) と [c4-dynamic-ci.md](./c4-dynamic-ci.md) を参照。

詳細な配置は [directory.md](../directory.md)、スタックは [tech.md](../tech.md)、セキュリティは [security.md](../security.md)。
