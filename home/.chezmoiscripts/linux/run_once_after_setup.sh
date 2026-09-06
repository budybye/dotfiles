#!/usr/bin/env bash
# Linux 初回 GUI セットアップ (chezmoi run_once → ~/.local/share/chezmoi/.../setup.sh)
# ロケール・xrdp・PipeWire 音声リダイレクトを構成する。make init / chezmoi apply --force で1回だけ実行。

set -eu

# root でないときだけ sudo を使う
sudo=""
if [ "$(id -u)" -ne 0 ]; then
    sudo="sudo"
fi

# xrdp リモートデスクトップ: 表示マネージャー・グループ・ファイアウォール
xrdp_setup() {
    echo "xrdp setup start..."
    if ! id -u xrdp >/dev/null 2>&1; then
        echo "xrdp user not found; installing xrdp packages."
        $sudo apt-get install -y --reinstall xrdp xorgxrdp
    fi
    
    if ! id -u xrdp >/dev/null 2>&1; then
        echo "xrdp user is still missing after package installation." >&2
        return 1
    fi
    
    if command -v xfce4-session >/dev/null 2>&1; then
        xfce_session="$(command -v xfce4-session)"
        $sudo update-alternatives --install /usr/bin/x-session-manager x-session-manager "${xfce_session}" 60
        $sudo update-alternatives --set x-session-manager "${xfce_session}"
    else
        echo "xfce4-session not found; skipping x-session-manager setup." >&2
    fi
    
    # wayland で起動する場合
    # startxfce4 --wayland

    $sudo apt-get install -y lightdm
    $sudo dpkg-reconfigure lightdm
    # リモートセッションで画面ロックが邪魔にならないよう削除
    # $sudo apt-get remove -y light-locker xscreensaver

    # xrdp は ssl-cert グループのメンバーが必要
    $sudo groupadd -f ssl-cert
    $sudo groupadd -f xrdp
    $sudo usermod -aG ssl-cert,xrdp "$(whoami)"
    $sudo adduser xrdp ssl-cert

    if command -v ufw >/dev/null 2>&1; then
        $sudo ufw allow 3389/tcp
        $sudo ufw reload
    fi

    if [ -d /run/systemd/system ] && command -v systemctl >/dev/null 2>&1; then
        $sudo systemctl enable xrdp
        $sudo systemctl start xrdp
        $sudo systemctl enable lightdm
        $sudo systemctl start lightdm
        $sudo systemctl daemon-reload
        $sudo systemctl restart rsyslog
        $sudo systemctl restart xrdp
    fi

    echo "xrdp setup completed."

    # ログイン後、ubuntu ユーザーのパスワード再設定を推奨
    echo "以下のコマンドを実行してパスワードを更新してください"
    echo "sudo passwd $(whoami)"
    # パスワードを再設定しないとログインできない?
    # echo "$(whoami):$(whoami)" | $sudo chpasswd
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

# xrdp 音声リダイレクト: PipeWire + pulseaudio-module-xrdp
# RDP クライアントの音声は module-xrdp-sink/source 経由。PipeWire では pipewire-pulse が Pulse 互換層になる。
pipewire_setup() {
    local build_root="${HOME}/.local/src"
    local pulse_src_dir="${HOME}/pulseaudio.src"
    local module_dir="${build_root}/pulseaudio-module-xrdp"
    local modlibexecdir

    echo "pipewire setup start..."

    $sudo apt-get update -y
    # pulseaudio デーモンは pipewire-audio / pipewire-pulse と競合する。
    # モジュールビルドには libpulse-dev と deb-src 由来のソースで足りる。
    if dpkg -s pulseaudio >/dev/null 2>&1; then
        $sudo apt-get remove -y pulseaudio
    fi
    
    $sudo apt-get install -y \
        build-essential \
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

    if [ -d /run/systemd/system ] && command -v systemctl >/dev/null 2>&1; then
        systemctl --user enable --now pipewire pipewire-pulse wireplumber
    fi

    echo "pipewire setup completed."
}

echo "setup.sh"
echo "--------------------------------"
xrdp_setup
pipewire_setup
echo "--------------------------------"
echo "GUI setup done!!"
echo "--------------------------------"
