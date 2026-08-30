---
name: platform-matrix
description: OS・CI・Docker の bootstrap 責務表
---

# Platform Matrix

| Environment | Mise config | Required | Warning / optional | Disabled |
|-------------|-------------|----------|--------------------|----------|
| Local macOS | `~/.config/mise.toml` | Mise, brew formula, defaults, launchd | cask, MAS, GUI apps | — |
| macOS CI | `~/.config/mise/ci.toml` | brew formula, defaults, launchd | brew-cask, MAS | Darwin hook bulk bootstrap |
| Ubuntu VM | `~/.config/mise.toml` | all apt packages | GUI installers | macOS defaults, launchd |
| Ubuntu CI | `~/.config/mise/ci.toml` | Linux CLI apt | — | GUI apt packages, systemd services |
| Docker build | `/home/ubuntu/.config/mise/docker.toml` | Linux CLI apt / image build | — | GUI apt, xrdp, PipeWire, SDDM, systemd |
| Windows | Chezmoi / native managers | existing PowerShell flow | — | Unix-only Mise bootstrap |

## Package ownership

```text
home/private_dot_config/mise.toml
└── local workstation full package set

home/private_dot_config/mise/ci.toml
├── macOS brew / brew-cask / MAS
└── Linux CLI apt

home/private_dot_config/mise/docker.toml
└── Linux CLI apt
```

Each profile is independently readable through `MISE_CONFIG_FILE` and contains `[bootstrap.packages]` only. Tool versions remain in `home/private_dot_config/mise/config.toml`.

## Service ownership

| Resource | Owner | Scope |
|----------|-------|-------|
| Docker systemd service | Mise `[bootstrap.services]` | Ubuntu VM only |
| Linux user service | Mise `[bootstrap.linux.systemd.units]` | Ubuntu user session only |
| macOS LaunchAgent | Mise `[bootstrap.macos.launchd.agents]` | macOS only |
| Docker daemon in container | Host / Docker Desktop / OrbStack | External to image |

## CI failure policy

```text
brew formula       → required, failure
brew-cask          → optional, continue, summary
mas                → optional, continue, summary
macOS defaults     → required, failure
macOS LaunchAgent  → required, failure
Ubuntu CLI apt     → required, failure
Ubuntu GUI app     → warning, continue
```

`disk8 ejected` is normal Homebrew cask DMG cleanup output. The workflow reports actual cask failure through the manager step outcome.
