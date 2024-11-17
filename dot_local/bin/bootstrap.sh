#!/usr/bin/env bash
set -ex

# Xcode コマンドラインツールのインストールおよびパスの設定
install_xcode_command_line_tools() {
    echo "Xcode command line tools check it..."
    command -v xcode-select -p >/dev/null || xcode-select --install || {
        echo "Xcode command line tools install failed."
        exit 1
    }
    echo "Xcode command line tools install done."
    CURRENT_PATH=$(xcode-select -p)
    DESIRED_PATH="/Library/Developer/CommandLineTools"

    if [ "$CURRENT_PATH" != "$DESIRED_PATH" ]; then
        echo "change path to $DESIRED_PATH"
        sudo xcode-select --switch "$DESIRED_PATH" || {
            echo "path change failed. reset initial settings."
            sudo xcode-select --reset
        }
    fi
    echo "$DESIRED_PATH setup done."
}

# Homebrew のインストールおよび設定
install_homebrew() {
    echo "Homebrew install check it..."
    command -v brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        echo "Homebrew install failed."
        exit 1
    }
    echo "Homebrew install done."
    eval "$(/opt/homebrew/bin/brew shellenv)"
}

# Brewfile を使用してパッケージをインストール
install_brew_packages() {
    BREWFILE_PATH="$HOME/.config/Brewfile"

    if [ -f "$BREWFILE_PATH" ]; then
        echo "Brewfile ($BREWFILE_PATH) install packages."
        brew tap Homebrew/bundle
        brew bundle --file="$BREWFILE_PATH" || {
            echo "brew bundle install failed"
            # exit 1
        }
    else
        echo "specified Brewfile ($BREWFILE_PATH) not found. skip."
    fi
    brew list
    echo "packages install done."
}

# Rosetta 2 のインストール (Apple Silicon の場合)
install_rosetta() {
    if [[ "$(uname -m)" == "arm64" ]]; then
        echo "Apple Silicon Mac detected. check Rosetta 2 install..."
        /usr/bin/pgrep oahd >/dev/null || /usr/sbin/softwareupdate --install-rosetta --agree-to-license || {
            echo "Rosetta 2 install failed."
            # exit 1
        }
    else
        echo "Rosetta 2 not needed (Intel Mac)."
    fi
    echo "Rosetta 2 install done."
}

# メイン処理
main() {
    echo "bootstrap start."
    install_xcode_command_line_tools
    install_homebrew
    install_brew_packages
    install_rosetta
    echo "bootstrap done."
    fastfetch || x
}

# script execution
main
