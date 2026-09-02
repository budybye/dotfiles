#!/usr/bin/env bash
set -eu

sudo=""
if [ "$(id -u)" -ne 0 ]; then
    sudo="sudo"
fi

# Zsh をデフォルトシェルに変更する関数
change_shell_to_zsh() {
    # zsh がインストールされているか確認
    if command -v zsh >/dev/null; then
        echo "zsh already installed."
    else
        $sudo apt-get install -y zsh || echo "zsh install failed."
    fi

    zsh_path=$(command -v zsh)
    if [ "${SHELL}" != "${zsh_path}" ]; then
        # デフォルトシェルを変更
        $sudo chsh -s "${zsh_path}" "$(whoami)" || echo "zsh default shell change failed."
    fi

    # ZDOTDIRを設定
    if [ -d "${HOME}/.config/zsh" ]; then
        export ZDOTDIR=${HOME}/.config/zsh
    else
        echo "zsh config directory not found."
        export ZDOTDIR="${HOME}"
    fi

    # シンボリックリンクを作成
    if [ ! -f /bin/zsh ] && [ -f /usr/bin/zsh ]; then
        $sudo ln -sf /usr/bin/zsh /bin/zsh
    fi

    echo "Your shell is ${SHELL}"
    echo "zsh default shell changed to ${zsh_path}."
    zsh --version || echo "zsh not found"
}

install_mise() {
    if command -v mise >/dev/null 2>&1; then
        echo "mise already installed."

    elif command -v curl >/dev/null 2>&1; then
        curl https://mise.run | sh || echo "mise install failed."

    else
        $sudo install -dm 755 /etc/apt/keyrings
        wget -qO - https://mise.jdx.dev/gpg-key.pub | $sudo gpg --dearmor | $sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1>/dev/null
        echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=$(dpkg --print-architecture)] https://mise.jdx.dev/deb stable main" | $sudo tee /etc/apt/sources.list.d/mise.list
        $sudo apt-get update -y
        $sudo apt-get install -y mise || echo "mise install failed."
    fi

    export PATH="${HOME}/.local/bin:${HOME}/.local/share/mise/shims:${HOME}/.local/share/mise/installs:$PATH"
    
    eval "$(mise activate bash)"

    mise --version || echo "mise not found"

    if [ -f "${HOME}/.config/mise.toml" ]; then
        mise bootstrap packages apply --manager apt -y || echo "mise bootstrap packages failed."
    fi
    
    if [ -f "${HOME}/.config/mise/config.toml" ]; then
        mise i -y || echo "mise install failed."
    fi

    echo "mise setup completed."
}

# 日本語ロケール・タイムゾーン・fcitx5 入力 systemd で分岐
japan_setup() {
    echo "japan setup start..."
    # Ubuntu のパッケージ名は locales (単数形 locale ではない)
    $sudo apt-get install -y language-pack-ja-base language-pack-ja manpages-ja tzdata locales fcitx5-mozc
    

    if [ -d /run/systemd/system ] && command -v systemctl >/dev/null 2>&1; then
        $sudo apt-get install -y im-config
        $sudo localectl set-locale LANG=ja_JP.UTF-8
        # localectl は LANGUAGE のコロン区切り値をロケールとして拒否するため update-locale を使う
        $sudo update-locale LANGUAGE=ja_JP:ja
        # コンテナ/Debian では keymap 設定非対応 ("Setting X11 and console keymaps is not supported in Debian.")
        if ! $sudo localectl set-x11-keymap jp; then
            echo "X11 keymap setup skipped (not supported on this system)." >&2
        fi
        
        if ! $sudo localectl set-keymap jp106; then
            echo "Console keymap setup skipped (not supported on this system)." >&2
        fi

        $sudo timedatectl set-timezone Asia/Tokyo
    # else
    #     # systemd なし (Docker 等): localectl/timedatectl は使えない
    #     $sudo locale-gen ja_JP.UTF-8
    #     $sudo update-locale LANG=ja_JP.UTF-8 LANGUAGE=ja_JP:ja LC_ALL=ja_JP.UTF-8
    #     $sudo ln -snf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
    #     echo 'Asia/Tokyo' | $sudo tee /etc/timezone >/dev/null
    fi

    if [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
        $sudo im-config -n fcitx5
    else
        echo "Skipping im-config: no graphical session."
    fi

    echo "japan setup completed."
}

install_flatpak() {
    if command -v flatpak >/dev/null 2>&1; then
        echo "flatpak already installed."
    else
        $sudo apt-get install -y flatpak || echo "flatpak install failed."
    fi
    $sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || echo "flatpak install failed.."
    flatpak --version || echo "flatpak not found"
}

install_go_aqua() {
    if command -v go >/dev/null 2>&1; then
        echo "go already installed."
    elif command -v mise >/dev/null 2>&1; then
        mise use -g -y go@latest || echo "go install failed."
    fi
    go version || echo "go not found"

    if command -v aqua >/dev/null 2>&1; then
        echo "aqua already installed."
    elif command -v mise >/dev/null 2>&1; then
        mise use -g -y aqua@latest || echo "aqua install failed."
    fi
    aqua --version || echo "aqua not found."
}

install_mkcert() {
    if command -v mkcert >/dev/null 2>&1; then
        echo "mkcert already installed."
    elif command -v mise >/dev/null 2>&1; then
        mise use -g -y mkcert@latest || echo "mkcert install failed."
    fi
    mkcert -install || echo "mkcert setup failed."
    mkcert --version || echo "mkcert not found."
}

install_coderabbit() {
    if command -v coderabbit >/dev/null 2>&1; then
        echo "coderabbit already installed."
    elif command -v curl >/dev/null 2>&1; then
        curl -fsSL https://cli.coderabbit.ai/install.sh | sh || echo "coderabbit install failed."
    fi
    coderabbit --version || echo "coderabbit not found."
}

echo "cli.sh"
echo "--------------------------------"
japan_setup
change_shell_to_zsh
install_mise
install_flatpak
install_go_aqua
install_mkcert
install_coderabbit
echo "CLI tools install done."
echo "--------------------------------"
