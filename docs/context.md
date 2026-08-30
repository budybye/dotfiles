---
name: context
description: Chezmoi と Mise の環境 profile 参照
---

# Context と profile

## Chezmoi context

Chezmoi の host context は `home/.chezmoi.toml.tmpl` が管理します。

```bash
chezmoi data
chezmoi doctor
```

```bash
# workstation
unset MISE_CONFIG_FILE
unset MISE_GLOBAL_CONFIG_FILE

# CI
export MISE_CONFIG_FILE="$HOME/.config/mise/ci.toml"
export MISE_GLOBAL_CONFIG_FILE="$HOME/.config/mise/config.toml"

# Docker
export MISE_CONFIG_FILE=/home/ubuntu/.config/mise/docker.toml
export MISE_GLOBAL_CONFIG_FILE=/home/ubuntu/.config/mise/config.toml
```

`MISE_CONFIG_FILE` selects the package profile. `MISE_GLOBAL_CONFIG_FILE` keeps `mise use -g` and tool installation writes in `config.toml`.

profile は `[bootstrap.packages]` 専用です。ツールの version 定義は常に次のファイルです。

```text
~/.config/mise/config.toml
```

profile を選択しても tool install はこのファイルを明示します。

```bash
MISE_CONFIG_FILE="$HOME/.config/mise/config.toml" mise install
```

## Profile policy

| Profile | macOS | Linux | GUI packages | services |
|---------|-------|-------|--------------|----------|
| workstation | full brew/cask/MAS | full apt | allowed | local only |
| ci | full brew/cask/MAS | CLI apt | Linux GUI excluded | workflow-managed macOS only |
| docker | ignored | CLI apt | excluded | excluded |

## Verification

```bash
mise config ls
mise bootstrap packages status
mise bootstrap packages apply --dry-run
```

`MISE_CONFIG_FILE` は実行するコマンドごとに確認してください。profile package と `config.toml` tools を混同しないことが重要です。
