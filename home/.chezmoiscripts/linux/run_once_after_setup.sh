#!/usr/bin/env bash

sudo=""
if [ "$(id -u)" -ne 0 ]; then
    sudo="sudo"
fi

japan_setup() {
    echo "japan setup start..."
    $sudo apt-get install -y language-pack-ja-base language-pack-ja manpages-ja
    $sudo apt-get install -y tzdata
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

    $sudo apt-get install -y lightdm
    $sudo dpkg-reconfigure lightdm
    # $sudo apt-get remove -y light-locker xscreensaver

    # $sudo groupadd -f ssl-cert
    # $sudo groupadd -f xrdp
    # $sudo usermod -aG ssl-cert,xrdp "$(whoami)"
    $sudo adduser xrdp ssl-cert

    $sudo ufw allow 3389/tcp
    $sudo ufw reload

    $sudo systemctl enable xrdp
    $sudo systemctl start xrdp
    $sudo systemctl enable lightdm
    $sudo systemctl start lightdm
    $sudo systemctl daemon-reload
    $sudo systemctl restart rsyslog
    # default session manager
    $sudo echo "xfce4-session" | tee ${HOME}/.xsession
    $sudo systemctl restart xrdp
    echo "xrdp setup completed."

    echo "以下のコマンドを実行してパスワードを更新してください"
    echo "sudo passwd $(whoami)"
    # ログイン後、ubuntuユーザーのパスワードを再設定を推奨
    # パスワードを再設定しないとログインできない?
    # echo "$(whoami):$(whoami)" | $sudo chpasswd
}

pipewire_setup() {
    doko=$(pwd)
    pulseaudio_dir="${HOME}/.config/pulseaudio"
    pipewire_dir="${HOME}/.config/pipewire/pulseaudio-module-xrdp"

    # pulseaudio をインストール
    $sudo apt-get install -y pulseaudio libpulse-dev dh-autoreconf dpkg-dev git || echo "pulseaudio install failed."

    mkdir -p "${pulseaudio_dir}"
    cd "${pulseaudio_dir}"
    git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git
    cd pulseaudio-module-xrdp
    $sudo make install
    ls $(pkg-config --variable=modlibexecdir libpulse) | grep xrdp || echo "pulseaudio xrdp module not found."
    cd "${doko}"

    # pipewire をインストール
    $sudo apt-get install -y pipewire pipewire-audio libspa-0.2-dev libpipewire-0.3-dev autoconf libtool && echo "pipewire installed." || echo "pipewire install failed."
    mkdir -p "${HOME}/.config/pipewire"

    if [ ! -d "${pipewire_dir}" ]; then
        git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git "${pipewire_dir}"
        cd "${pipewire_dir}"
        ./bootstrap

        # PULSE_DIR を pulseaudio ソースのディレクトリに設定
        export PULSE_DIR=~/pulseaudio

        ./configure PULSE_DIR="${PULSE_DIR}" PULSE_CONFIG_DIR="${PULSE_DIR}"
        make
        $sudo make install
        cd "${doko}"
    fi
    echo "pipewire installed."
}

echo "setup.sh"
echo "--------------------------------"

japan_setup
xrdp_setup
pipewire_setup

echo "--------------------------------"
echo "GUI setup done!!"
echo "--------------------------------"
