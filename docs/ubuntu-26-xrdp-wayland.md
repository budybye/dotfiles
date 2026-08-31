---
name: ubuntu-26-xrdp-wayland
description: Ubuntu 26.04 の xrdp / XFCE / Wayland / display manager 調査
---

# Ubuntu 26.04: xrdp / XFCE / Wayland / Display Manager

## Executive conclusion

- Ubuntu 26.04 で xrdp を使う安定構成は **xrdp + xorgxrdp + Xorg + XFCE**。xrdp upstream は通常の Linux desktop 接続に `xorgxrdp` が必要と説明している。[xrdp README](https://github.com/neutrinolabs/xrdp)、[xorgxrdp README](https://github.com/neutrinolabs/xorgxrdp)
- xrdp は native Wayland desktop を直接起動する構成ではない。upstream の Wayland 対応は継続中で、現時点の通常運用は Xorg backend を使う。[xrdp Wayland discussion](https://github.com/neutrinolabs/xrdp/discussions/3634)
- XFCE 4.20 は Wayland を preliminary / experimental にサポートするが、X11 も維持している。xrdp では XFCE の Xorg セッションを選ぶ。[XFCE Wayland roadmap](https://wiki.xfce.org/releng/wayland_roadmap)、[XFCE 4.20 roadmap](https://wiki.xfce.org/releng/4.20/roadmap)
- display manager は xrdp のリモートセッション起動に必須ではない。xrdp の `xrdp-sesman` がユーザーセッションを管理するため、headless xrdp host に SDDM/GDM3/LightDM を追加する理由はない。これは xrdp の sesman 構成からの判断であり、ログイン画面用途との混同を避ける。[xrdp source](https://github.com/neutrinolabs/xrdp)
- このリポジトリでは、Ubuntu VM の full GUI profile だけに xrdp/XFCE を置き、Docker/Dev Container は CLI を基本にするのが適切。GUI が必要な場合だけ full image を選ぶ。

## Ubuntu 26.04 package matrix

Ubuntu 26.04 arm64 の公式 package metadata / package index で確認できる主要候補:

| Package | Role | 26.04 status | Recommendation |
|---------|------|--------------|----------------|
| `xrdp` | RDP server + sesman integration | `0.10.1-4.1`, Universe | Ubuntu VM full profile |
| `xorgxrdp` | Xorg modules for xrdp | `1:0.10.2-1build1`, Universe | Always pair with xrdp |
| `xfce4` | XFCE desktop meta package | Resolvable in Resolute | Ubuntu VM full profile |
| `xfce4-session` | XFCE session executable | `4.20.4-1`, Universe | Required for `startxfce4` |
| `freerdp-x11` | FreeRDP X11 client | `3.30.0+dfsg-0ubuntu0.26.04.2` | Optional client |
| `lightdm` | Local graphical display manager | `1.32.0-6ubuntu4`, Universe | Only if local greeter is needed |
| `sddm` | Qt/QML local display manager | `0.21.0+git20250502.4fe234b-2ubuntu3`, Universe | Do not install for xrdp-only host |
| `gdm3` | GNOME display manager | Available in Ubuntu package search | Only for GNOME local login |

Sources: [Ubuntu xrdp package](https://packages.ubuntu.com/resolute/arm64/xrdp), [Ubuntu xorgxrdp package](https://packages.ubuntu.com/resolute/arm64/xorgxrdp), [Ubuntu xfce4-session package](https://packages.ubuntu.com/eu/resolute/xfce4-session), [Ubuntu lightdm package](https://packages.ubuntu.com/resolute/amd64/lightdm), [Ubuntu package search: sddm](https://packages.ubuntu.com/search?arch=arm64&keywords=sddm), [Ubuntu package search: gdm3](https://packages.ubuntu.com/search?keywords=gdm3).

Ubuntu 26.04 renamed the release codename to Resolute and changed several package versions. Package names must be checked against Resolute, not copied from Ubuntu 24.04 examples.[Ubuntu 26.04 release notes](https://documentation.ubuntu.com/release-notes/26.04/summary-for-lts-users/)

## xrdp / XFCE / Wayland flow

```text
RDP client
  → xrdp.service :3389
    → xrdp-sesman
      → Xorg + xorgxrdp modules
        → XFCE X11 session
          → ~/.xsession or startwm.sh
```

- `xrdp` accepts the RDP connection and delegates user session management to sesman.[xrdp README](https://github.com/neutrinolabs/xrdp)
- `xorgxrdp` is not a desktop environment; it provides modules that make an existing X.Org server work with xrdp.[xorgxrdp README](https://github.com/neutrinolabs/xorgxrdp)
- XFCE should be launched as an X11 session for this flow. A `.xsession` containing `startxfce4` or an equivalent `startwm.sh` branch is the relevant session boundary.
- `xrdp` and `xorgxrdp` must be installed before configuring `xrdp` users, `ssl-cert` membership, or the session manager alternative.

## Wayland status

XFCE 4.20's roadmap describes Wayland support as preliminary. The project continues to preserve X11 support while filling gaps in session management, panel integration, settings, compositing, and other desktop components.[XFCE Wayland roadmap](https://wiki.xfce.org/releng/wayland_roadmap)

xrdp's supported mainstream path remains Xorg/xorgxrdp. Native Wayland sessions are not a drop-in replacement for the current xrdp flow; upstream discussions describe Wayland work as ongoing and compositor-specific.[xrdp issue/discussion index](https://github.com/neutrinolabs/xrdp/issues)、[xrdp Wayland discussion](https://github.com/neutrinolabs/xrdp/discussions/3634)

**Decision:** Do not add Wayland-specific xrdp branches to this dotfiles setup. Keep `startxfce4` / Xorg for remote desktop. Treat XFCE Wayland as a separate experiment, not as the default.

## Display manager comparison

| Manager | Owns | Needed by xrdp? | Use here |
|---------|------|-----------------|----------|
| LightDM | Local graphical greeter and local sessions | No | Optional on an Ubuntu desktop that needs a lightweight local login |
| SDDM | Local Qt/QML greeter and local sessions, X11/Wayland selection | No | Avoid for xrdp-only; may conflict with LightDM/GDM3 |
| GDM3 | GNOME local greeter and GNOME sessions | No | Use only for a GNOME workstation |
| None | No local greeter | No, for headless xrdp | Preferred for headless xrdp server |

LightDM is described as a lightweight cross-desktop display manager by its upstream project.[LightDM](https://github.com/canonical/lightdm)

SDDM is a QtQuick display manager for local X11/Wayland login sessions.[SDDM](https://github.com/sddm/sddm)

GDM is GNOME's graphical login manager.[GNOME GDM documentation](https://help.gnome.org/admin/system-admin-guide/stable/login.html.en)

**Operational rule:** choose at most one local display manager. Installing SDDM only to make xrdp work is unnecessary. If a system already has LightDM or GDM3, do not switch it as part of xrdp setup unless local login ownership is an explicit requirement.

## Current repository risks

### 1. `update-alternatives` assumption

The old setup called `update-alternatives --set x-session-manager /usr/bin/xfce4-session` before ensuring that the alternative group and candidate existed. Ubuntu 26.04 can report `no alternatives for x-session-manager`. Use `--install` first, then `--set`, and only after `xfce4-session` is installed.

### 2. Display-manager side effects

The current setup installs SDDM even though xrdp does not require it. SDDM can conflict with an existing `display-manager.service` symlink and adds a local graphical login concern to a remote desktop setup. Remove SDDM from the xrdp path unless local SDDM login is explicitly required.

### 3. Package ordering

`xrdp` creates the `xrdp` system user during package installation. Any `usermod xrdp`, `adduser xrdp ssl-cert`, or `systemctl enable xrdp` operation must happen after package convergence. Missing-user errors indicate an ordering problem, not a Wayland problem.

### 4. Container assumptions

A Docker/Dev Container normally has no systemd PID 1, no user graphical session, and no display manager. `privileged: true` does not make a container a complete VM. Installing XFCE/xrdp can make the image large, but it does not provide a reliable desktop lifecycle without an explicit init/RDP runtime design.

The current `.devcontainer/Dockerfile` is a GUI-capable image with XFCE/xrdp packages and ports 3389/22. Keep that as an explicit full image if RDP is required; make CLI the default image for ordinary Dev Container work.

## Recommended architecture

```text
Ubuntu VM / desktop
├── Mise [bootstrap.packages]
│   ├── xrdp
│   ├── xorgxrdp
│   ├── xfce4
│   └── xfce4-session
├── one local display manager only if local login is needed
├── systemd xrdp service
└── Xorg XFCE session

Docker / Dev Container default
├── Dockerfile + Chezmoi
├── Mise tools / CLI package profile
└── no display manager, xrdp, or systemd service

Docker full GUI (explicit)
├── GUI packages
├── xrdp
└── dedicated runtime/init validation
```

## Migration checklist

- [ ] Pin Ubuntu 26.04 package names to Resolute candidates.
- [ ] Keep `xrdp` + `xorgxrdp` + `xfce4-session` together.
- [ ] Register `x-session-manager` with `update-alternatives --install` before `--set`.
- [ ] Remove SDDM from xrdp setup unless local SDDM login is required.
- [ ] Configure `.xsession` / `startwm.sh` for XFCE X11, not native Wayland.
- [ ] Keep exactly one local display manager where one is needed.
- [ ] Guard `systemctl` operations on actual systemd availability.
- [ ] Do not run `im-config` during Docker build without a graphical session.
- [ ] Keep GUI/xrdp image explicit; use CLI Dev Container by default.
- [ ] Test Ubuntu VM and container separately; a successful image build does not prove xrdp runtime.

## Sources

- [xrdp upstream](https://github.com/neutrinolabs/xrdp)
- [xorgxrdp upstream](https://github.com/neutrinolabs/xorgxrdp)
- [xrdp Wayland discussion](https://github.com/neutrinolabs/xrdp/discussions/3634)
- [XFCE Wayland roadmap](https://wiki.xfce.org/releng/wayland_roadmap)
- [XFCE 4.20 roadmap](https://wiki.xfce.org/releng/4.20/roadmap)
- [Ubuntu 26.04 release notes](https://documentation.ubuntu.com/release-notes/26.04/summary-for-lts-users/)
- [Ubuntu xrdp package](https://packages.ubuntu.com/resolute/arm64/xrdp)
- [Ubuntu xorgxrdp package](https://packages.ubuntu.com/resolute/arm64/xorgxrdp)
- [Ubuntu xfce4-session package](https://packages.ubuntu.com/eu/resolute/xfce4-session)
- [Canonical LightDM](https://github.com/canonical/lightdm)
- [SDDM](https://github.com/sddm/sddm)
- [GNOME GDM documentation](https://help.gnome.org/admin/system-admin-guide/stable/login.html.en)
