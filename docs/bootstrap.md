---
name: bootstrap
description: Chezmoi + Mise bootstrap 運用手順
---

# Bootstrap 運用手順

## Local macOS

```bash
make init
```

`make init` は `install.sh` → Chezmoi apply → Darwin bootstrap → Mise tools の順で実行します。local macOS では formula、cask、MAS、macOS defaults、MPD LaunchAgent を対象にします。

Windows App は Mise の cask installer choices 未対応のため、必要な場合だけ実行します。

```bash
mise run macos-install-windows-app
```

## GitHub Actions

Mac job は個人 workstation の package profile を使いますが、manager 単位で実行します。

```text
make init
  └── Darwin hook の一括 Mise bootstrap は skip
mise bootstrap packages apply --manager brew -y
mise bootstrap packages apply --manager brew-cask -y  # warning 継続
mise bootstrap packages apply --manager mas -y         # warning 継続
mise bootstrap macos defaults apply -y
mise bootstrap macos launchd-agents apply -y
```

cask / MAS の失敗は job を止めず、`GITHUB_STEP_SUMMARY` に記録します。defaults と LaunchAgent の失敗は job failure です。timeout は 60 分です。

## Ubuntu VM

```bash
make init
```

Ubuntu VM は workstation profile の全 apt package を対象にします。apt failure は必須扱いです。GUI installer（Zed、Zen、GitHub Desktop、Element、WARP）の failure は warning として扱います。

## Ubuntu CI

workflow が次の profile を選択します。

```bash
export MISE_CONFIG_FILE="$HOME/.config/mise/ci.toml"
make init
```

`ci.toml` は Linux CLI package だけを対象にし、XFCE、xrdp、PipeWire、SDDM、system service は含めません。

## Docker

Dockerfile は build 前に profile を指定します。

```dockerfile
ENV MISE_CONFIG_FILE=/home/ubuntu/.config/mise/docker.toml
```

`docker.toml` は Linux CLI package だけを対象にします。systemd service、Docker daemon、GUI package は Docker build 内で管理しません。現在の GUI image は full image として維持します。

## Image tags

移行中の対応:

```text
ubuntu-dev:full                  # 汎用 GUI image
ubuntu-dev:dev                   # devcontainers/ci image
ubuntu-dev:slim                  # 移行期間のみ full alias
ubuntu-dev:linux-amd64-full
ubuntu-dev:linux-arm64-full
ubuntu-dev:linux-amd64-dev
ubuntu-dev:linux-arm64-dev
```

CLI-only image は別変更で `.devcontainer/Dockerfile.cli` として追加します。両 architecture の build、pull、起動、CLI smoke test が通過した後に `slim` を CLI-only へ repurpose し、`latest` / semver を移します。

## Recovery

```bash
# optional manager を再試行
mise bootstrap packages apply --manager brew-cask -y
mise bootstrap packages apply --manager mas -y

# profile の確認
mise config ls
mise bootstrap packages status
```
