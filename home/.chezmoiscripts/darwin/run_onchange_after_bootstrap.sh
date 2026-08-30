#!/usr/bin/env bash
# set -eu

# Xcode コマンドラインツールのインストールおよびパスの設定
install_xcode_command_line_tools() {
    echo "Xcode command line tools check it..."
    if xcode-select -p >/dev/null 2>&1; then
        echo "Xcode command line tools already installed."
    else
        xcode-select --install || echo "Xcode command line tools install failed."
        echo "Xcode command line tools install done."
    fi
    CURRENT_PATH=$(xcode-select -p)
    DESIRED_PATH="/Library/Developer/CommandLineTools"

    if [ "$CURRENT_PATH" != "$DESIRED_PATH" ]; then
        echo "change path to $DESIRED_PATH"
        sudo xcode-select --switch "$DESIRED_PATH" || {
            echo "path change failed. reset initial settings."
            sudo xcode-select --reset
        }
        echo "$DESIRED_PATH setup done."
    fi
}

install_rosetta() {
    if [[ "$(uname -m)" == "arm64" ]]; then
        echo "Apple Silicon Mac detected. check Rosetta 2 install..."
        /usr/bin/pgrep oahd >/dev/null || /usr/sbin/softwareupdate --install-rosetta --agree-to-license || echo "Rosetta 2 install failed."
    else
        echo "Rosetta 2 not needed (Intel Mac)."
    fi
    echo "Rosetta 2 install done."
}

install_homebrew() {
    echo "Homebrew install check it..."
    if command -v brew >/dev/null 2>&1; then
        echo "Homebrew already installed."
    else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || echo "Homebrew install failed."
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo "Homebrew installed."
    fi
}

install_mise() {
    if command -v mise >/dev/null; then
        echo "mise already installed."
    else
        curl https://mise.run | sh 
        mise --version || echo "mise install failed."
    fi

    eval "$(mise activate bash)"

    if [ -f "${HOME}/.config/mise.toml" ]; then
        mise bootstrap packages apply --manager brew -y || echo "mise bootstrap failed."
        mise bootstrap packages apply --manager brew-cask -y || echo "mise bootstrap failed."
        # mise bootstrap packages apply --manager mas -y || echo "mise bootstrap failed."
    fi
    
    if [ -f "${HOME}/.config/mise/config.toml" ]; then
        mise i -y || echo "mise install failed."
    fi
    
    echo "mise setup completed."
}

echo "bootstrap.sh"
echo "--------------------------------"
install_xcode_command_line_tools
install_rosetta
install_homebrew
install_mise
echo "--------------------------------"
echo "zsh --version $(zsh --version)"
echo "--------------------------------"
echo "Package install && update done!!"
echo "--------------------------------"
