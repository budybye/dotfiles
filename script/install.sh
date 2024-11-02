#!/bin/sh

## コンピュータ名、ホスト名、ローカルホスト名、ユーザー名を設定
# sudo scutil --set ComputerName "iCom"
# sudo scutil --set HostName "101"
# sudo scutil --set LocalHostName "101"
# sudo scutil --set UserName "hotmilk"

## (スリープ状態に移行するまでの時間，単位は秒(24時間))
sudo pmset -a standbydelay 86400

## xcode commond tool install
xcode-select --install && \
sudo xcode-select --switch /Library/Developer/CommandLineTools

## homebrew をインストールされていなければインストールする
if ! command -v brew >/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# brewのPATHを通す
# brewコマンドが実行可能な場合evalを実行する
if command -v brew >/dev/null; then
    eval "$(brew shellenv)"
else
    echo "brew is not installed"
    echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshenv
    source ~/.zshenv
fi

# Brewfileからインストールする
brew tap Homebrew/bundle && brew bundle --file '~/.config/Brewfile'

# Rosetta2 のインストール
softwareupdate --install-rosetta
