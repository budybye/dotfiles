# C4 — Deployment (Level 4)

**Scope:** ローカルホスト・Dev Container・CI / GHCR・任意 VM への配置。  
**Audience:** DevOps / 自分自身の環境再現手順の把握。

## 図

```mermaid
C4Deployment
  title Deployment Diagram for Personal Dotfiles

  Deployment_Node(devMachine, "Developer machine", "macOS / Ubuntu") {
    Deployment_Node(hostFs, "Host filesystem", "XDG / $HOME") {
      Container(homeLayout, "Applied configs", "POSIX FS", "~/.config, ~/.local, ~/.ssh")
    }
    Deployment_Node(localCli, "Local tooling", "shell") {
      Container(chezmoiCli, "Chezmoi CLI", "chezmoi", "template / apply")
      Container(srcTree, "Working copy", "Git", "dotfiles clone")
    }
  }

  Deployment_Node(dockerHost, "Docker host", "Compose / Dev Containers") {
    Deployment_Node(ubuntuDev, "ubuntu-dev", "linux/amd64|arm64") {
      Container(devCtr, "Dev container", "Ubuntu 24.04 + Xfce/xrdp", "SSH:2222 RDP:33389")
    }
  }

  Deployment_Node(github, "GitHub", "cloud") {
    Deployment_Node(actions, "GitHub Actions", "runners") {
      Container(ci, "CI workflows", "YAML", "test / tag / push / ipfs")
    }
    Deployment_Node(ghcr, "GHCR", "container registry") {
      Container(image, "ubuntu-dev image", "ghcr.io/budybye/ubuntu-dev", "semver / latest")
    }
  }

  Deployment_Node(vmHost, "Optional VM", "Multipass / LXD") {
    Container(cloudInitVm, "Cloud-init guest", "Ubuntu", "cloud-init/*.yaml で初期化")
  }

  Rel(chezmoiCli, srcTree, "ソース読取")
  Rel(chezmoiCli, homeLayout, "apply で反映")
  Rel(srcTree, ci, "push でトリガ", "git")
  Rel(ci, image, "build & push", "Docker Buildx")
  Rel(devCtr, image, "pull して起動可", "OCI")
  Rel(cloudInitVm, srcTree, "bootstrap で clone / apply")
```

## 配置メモ

- **ローカル:** `curl | chezmoi init --apply` または `make init` → `install.sh`。
- **コンテナ:** `.devcontainer/`（`make docker-run`）。ポートは RDP `33389→3389`、SSH `2222→22`。
- **CI 成果物:** semver タグ後に `ghcr.io/budybye/ubuntu-dev` を push（`push.yaml`）。`ipfs.yaml` はコンテナと独立して main をピン。
- **VM:** `make vm-create` + `cloud-init/`。

パイプライン詳細は [tech.md](../tech.md#github-actions-パイプライン) と [c4-dynamic-ci.md](./c4-dynamic-ci.md)。
