# C4 — Dynamic: CI / Release パイプライン

**用途:** `main` push からテスト・タグ・GHCR・IPFS までの流れ。

## 図

```mermaid
C4Dynamic
  title Dynamic Diagram for CI Release Pipeline

  Person(owner, "Machine owner", "main へ push")
  Container(repo, "GitHub repository", "Git", "budybye/dotfiles")
  Container(testWf, "test.yaml", "Actions", "多 OS で make init 検証")
  Container(tagWf, "tag.yaml", "Actions", "semver +1 と Release")
  Container(pushWf, "push.yaml", "Actions", "GHCR build & push")
  Container(ipfsWf, "ipfs.yaml", "Actions", "IPFS ピン")
  Container_Ext(ghcr, "GHCR", "registry", "ghcr.io/budybye/ubuntu-dev")
  Container_Ext(ipfs, "IPFS / Filebase", "pinning", "ミラー")

  Rel(owner, repo, "1. push to main（docs 以外）", "git")
  Rel(repo, testWf, "2. インストール検証を起動", "workflow")
  Rel(repo, ipfsWf, "3. 並行してピン", "workflow")
  Rel(ipfsWf, ipfs, "4. コンテンツをピン", "API")
  Rel(testWf, tagWf, "5. 成功時に workflow_run", "Actions")
  Rel(tagWf, repo, "6. semver タグ + Release", "git / API")
  Rel(tagWf, pushWf, "7. gh workflow run push.yaml", "dispatch")
  Rel(pushWf, ghcr, "8. multi-arch イメージを push", "Buildx")
```

## 補足

- `docs/**` とルート `*.md` の変更は `test.yaml` の `paths-ignore` 対象。
- `push.yaml` は **main 単独 push では走らない**（`latest` と Release 済みイメージのズレ防止）。
- バージョンの単一ソースは git の semver タグ（`make version` / `DOTFILES_VERSION`）。

詳細は [tech.md](../tech.md#github-actions-パイプライン)。
