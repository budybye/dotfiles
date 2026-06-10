#!/usr/bin/env bash
# Linux 初回 GUI セットアップ (chezmoi run_once → ~/.local/share/chezmoi/.../setup.sh)
# ロケール・xrdp・PipeWire 音声リダイレクトを構成する。make init / chezmoi apply --force で1回だけ実行。
set -eu

# root でないときだけ sudo を使う
sudo=""
if [ "$(id -u)" -ne 0 ]; then
    sudo="sudo"
fi

# システム systemd が動いているか (VM/ベアメタル向け。コンテナでは false)
systemd_running() {
    command -v systemctl >/dev/null 2>&1 && systemctl is-system-running >/dev/null 2>&1
}

# ユーザーセッションの systemd が動いているか (ログイン済み GUI セッション向け)
user_systemd_running() {
    [ -n "${XDG_RUNTIME_DIR:-}" ] && systemctl --user is-system-running >/dev/null 2>&1
}

# pulseaudio-module-xrdp が libpulse の modlibexecdir に入っているか
xrdp_pulse_modules_installed() {
    local modlibexecdir match
    modlibexecdir="$(pkg-config --variable=modlibexecdir libpulse)"
    for match in "${modlibexecdir}"/*xrdp*; do
        if [ -e "${match}" ]; then
            return 0
        fi
    done
    return 1
}

# pulseaudio-module-xrdp のビルドに必要な deb-src を有効化 (Ubuntu 24.04+ の .sources 形式)
enable_pulse_deb_src() {
    if [ -f /etc/apt/sources.list.d/ubuntu.sources ] && ! grep -q 'deb-src' /etc/apt/sources.list.d/ubuntu.sources; then
        $sudo sed -i 's/Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources
        $sudo apt-get update -y
    fi
}

# xrdp セッション起動時に XFCE を開始する。.xsession は xrdp が読む。
# user systemd がある環境では pipewire 等は systemd --user が起動するので xfce4-session のみ。
# systemd がない環境 (一部コンテナ) では pipewire を手動起動してから xfce4-session へ。
write_xsession() {
    if user_systemd_running; then
        printf '%s\n' 'xfce4-session' > "${HOME}/.xsession"
    else
        cat > "${HOME}/.xsession" <<'XSESSION'
#!/bin/sh
if command -v pipewire >/dev/null 2>&1; then
    pipewire &
    wireplumber &
    pipewire-pulse &
fi
exec xfce4-session
XSESSION
        chmod +x "${HOME}/.xsession"
    fi
}

# 日本語ロケール・タイムゾーン・fcitx5 入力
japan_setup() {
    echo "japan setup start..."
    # Ubuntu のパッケージ名は locales (単数形 locale ではない)
    $sudo apt-get install -y language-pack-ja-base language-pack-ja manpages-ja tzdata locales
    $sudo apt-get install -y fcitx5-mozc im-config

    if systemd_running; then
        $sudo localectl set-locale LANG=ja_JP.UTF-8
        $sudo localectl set-locale LANGUAGE=ja_JP:ja
        # コンテナ/Debian では keymap 設定非対応 ("Setting X11 and console keymaps is not supported in Debian.")
        if ! $sudo localectl set-x11-keymap jp; then
            echo "X11 keymap setup skipped (not supported on this system)." >&2
        fi
        if ! $sudo localectl set-keymap jp106; then
            echo "Console keymap setup skipped (not supported on this system)." >&2
        fi
        $sudo timedatectl set-timezone Asia/Tokyo
    else
        # systemd なし (Docker 等): localectl/timedatectl は使えない
        $sudo locale-gen ja_JP.UTF-8
        $sudo update-locale LANG=ja_JP.UTF-8 LANGUAGE=ja_JP:ja LC_ALL=ja_JP.UTF-8
        $sudo ln -snf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
        echo 'Asia/Tokyo' | $sudo tee /etc/timezone >/dev/null
    fi

    $sudo im-config -n fcitx5
    echo "japan setup completed."
}

# xrdp リモートデスクトップ: 表示マネージャー・グループ・ファイアウォール
xrdp_setup() {
    echo "xrdp setup start..."
    # デフォルトのセッションマネージャーを xfce4-session に設定
    $sudo update-alternatives --set x-session-manager /usr/bin/xfce4-session
    # $sudo update-alternatives --set x-session-manager /usr/bin/startxfce4

    # wayland で起動する場合
    # startxfce4 --wayland

    # packages.yaml の linux.gui と揃える (sddm)
    # $sudo apt-get install -y lightdm
    # $sudo apt-get install -y gdm3
    $sudo apt-get install -y sddm

    # $sudo dpkg-reconfigure lightdm
    # リモートセッションで画面ロックが邪魔にならないよう削除
    $sudo apt-get remove -y light-locker xscreensaver

    # xrdp は ssl-cert グループのメンバーが必要
    $sudo groupadd -f ssl-cert
    $sudo groupadd -f xrdp
    $sudo usermod -aG ssl-cert,xrdp "$(whoami)"
    $sudo adduser xrdp ssl-cert

    if command -v ufw >/dev/null 2>&1; then
        $sudo ufw allow 3389/tcp
        $sudo ufw reload
    fi

    if systemd_running; then
        $sudo systemctl enable xrdp
        $sudo systemctl start xrdp
        # $sudo systemctl enable lightdm
        # $sudo systemctl start lightdm
        $sudo systemctl daemon-reload
        $sudo systemctl restart rsyslog
        $sudo systemctl restart xrdp
    fi

    echo "xrdp setup completed."

    echo "以下のコマンドを実行してパスワードを更新してください"
    echo "sudo passwd $(whoami)"
    # ログイン後、ubuntu ユーザーのパスワード再設定を推奨
    # パスワードを再設定しないとログインできない?
    # echo "$(whoami):$(whoami)" | $sudo chpasswd
}

# xrdp 音声リダイレクト: PipeWire + pulseaudio-module-xrdp
# RDP クライアントの音声は module-xrdp-sink/source 経由。PipeWire では pipewire-pulse が Pulse 互換層になる。
pipewire_setup() {
    local build_root="${HOME}/.local/src"
    local pulse_src_dir="${HOME}/pulseaudio.src"
    local module_dir="${build_root}/pulseaudio-module-xrdp"
    local modlibexecdir

    echo "pipewire setup start..."

    $sudo apt-get update -y
    $sudo apt-get install -y \
        build-essential \
        pulseaudio \
        libpulse-dev \
        dh-autoreconf \
        dpkg-dev \
        git \
        lsb-release \
        pipewire \
        pipewire-audio \
        pipewire-pulse \
        wireplumber \
        libspa-0.2-dev \
        libpipewire-0.3-dev \
        autoconf \
        libtool

    if xrdp_pulse_modules_installed; then
        echo "xrdp pulse modules already installed."
    else
        enable_pulse_deb_src
        mkdir -p "${build_root}"
        if [ ! -d "${module_dir}/.git" ]; then
            git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git "${module_dir}"
        fi

        cd "${module_dir}"

        # ディストロの pulseaudio ソースを取得 (configure が PULSE_DIR を要求する)
        if [ ! -d "${pulse_src_dir}" ]; then
            ./scripts/install_pulseaudio_sources_apt.sh -d "${pulse_src_dir}"
        fi

        # 公式手順: bootstrap → configure → make → install
        ./bootstrap
        ./configure PULSE_DIR="${pulse_src_dir}"
        make
        $sudo make install

        if ! xrdp_pulse_modules_installed; then
            modlibexecdir="$(pkg-config --variable=modlibexecdir libpulse)"
            echo "pulseaudio xrdp modules not found in ${modlibexecdir}" >&2
            exit 1
        fi
    fi

    if user_systemd_running; then
        systemctl --user enable --now pipewire pipewire-pulse wireplumber
    fi

    echo "pipewire setup completed."
}

echo "setup.sh"
echo "--------------------------------"

japan_setup
xrdp_setup
pipewire_setup
write_xsession

echo "--------------------------------"
echo "GUI setup done!!"
echo "--------------------------------"
