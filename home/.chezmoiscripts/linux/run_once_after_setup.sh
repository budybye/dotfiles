#!/usr/bin/env bash
set -eu

sudo=""
if [ "$(id -u)" -ne 0 ]; then
    sudo="sudo"
fi

systemd_running() {
    command -v systemctl >/dev/null 2>&1 && systemctl is-system-running >/dev/null 2>&1
}

user_systemd_running() {
    [ -n "${XDG_RUNTIME_DIR:-}" ] && systemctl --user is-system-running >/dev/null 2>&1
}

xrdp_pulse_modules_installed() {
    local modlibexecdir
    modlibexecdir="$(pkg-config --variable=modlibexecdir libpulse)"
    ls "${modlibexecdir}" 2>/dev/null | grep -q xrdp
}

enable_pulse_deb_src() {
    if [ -f /etc/apt/sources.list.d/ubuntu.sources ] && ! grep -q 'deb-src' /etc/apt/sources.list.d/ubuntu.sources; then
        $sudo sed -i 's/Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources
        $sudo apt-get update -y
    fi
}

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

japan_setup() {
    echo "japan setup start..."
    $sudo apt-get install -y language-pack-ja-base language-pack-ja manpages-ja tzdata locale
    $sudo apt-get install -y fcitx5-mozc im-config

    $sudo localectl set-locale LANG=ja_JP.UTF-8
    $sudo localectl set-locale LANGUAGE=ja_JP:ja
    $sudo localectl set-x11-keymap jp
    $sudo localectl set-keymap jp106
    $sudo timedatectl set-timezone Asia/Tokyo
    # LANG=C xdg-user-dirs-update --force
    $sudo im-config -n fcitx5
    echo "japan setup completed."
}

xrdp_setup() {
    echo "xrdp setup start..."
    # デフォルトのセッションマネージャーをxfce4-sessionに設定
    $sudo update-alternatives --set x-session-manager /usr/bin/xfce4-session
    # $sudo update-alternatives --set x-session-manager /usr/bin/startxfce4

    # wayland で起動する場合
    # startxfce4 --wayland

    # packages.yaml の linux.gui と揃える (sddm)
    # $sudo apt-get install -y lightdm
    # $sudo apt-get install -y gdm3
    $sudo apt-get install -y sddm

    # $sudo dpkg-reconfigure lightdm
    $sudo apt-get remove -y light-locker xscreensaver

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
    # ログイン後、ubuntuユーザーのパスワードを再設定を推奨
    # パスワードを再設定しないとログインできない?
    # echo "$(whoami):$(whoami)" | $sudo chpasswd
}

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

        if [ ! -d "${pulse_src_dir}" ]; then
            ./scripts/install_pulseaudio_sources_apt.sh -d "${pulse_src_dir}"
        fi

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
