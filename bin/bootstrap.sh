#!/usr/bin/env/ bash -x

## スリープ状態に移行するまでの時間，単位は秒(24時間)
# sudo pmset -a standbydelay 86400

# xcode commond tool install
xcode-select --install > /dev/null
sudo xcode-select --switch /Library/Developer/CommandLineTools > /dev/null 2>&1

# brewコマンドが実行可能な場合evalを実行する
# homebrew をインストールされていなければインストールする
# brewのPATHを通す
if command -v brew > /dev/null 2>&1; then
    eval "$(brew shellenv)"
else
    echo "brew is not installed"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'export PATH="/opt/homebrew/bin:$PATH"' >> "${HOME}/.zshenv"
    . "${HOME}/.zshenv"
fi

# Brewfileからインストールする
# brew tap Homebrew/bundle && brew bundle --file "${XDG_CONFIG_HOME}/Brewfile"
brew tap Homebrew/bundle && brew bundle --file "${XDG_CONFIG_HOME}/Brewfile-test"

# Rosetta2 のインストール
# softwareupdate --install-rosetta
