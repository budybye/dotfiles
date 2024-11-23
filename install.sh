#! /usr/bin/env bash

# chezmoi のインストールと初期化
USER=$(whoami)
AUTHOR=budybye
BIN=${HOME}/.local/bin
DOTFILES=${HOME}/dotfiles
REPO=https://github.com/${AUTHOR}/dotfiles.git

echo "--------------------------------"
# chezmoi 用の環境変数を指定 例: dev, runner, lisa,  etc...
export CONTEXT=${USER}
echo "--------------------------------"
# chezmoi がインストールされていない場合はインストール
if ! command -v chezmoi >/dev/null 2>&1; then
    echo "${USER} install chezmoi to ${BIN}..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ${BIN}
    export PATH=${BIN}:${PATH}
fi
echo "--------------------------------"

chezmoi init --apply ${AUTHOR}
# chezmoi init --apply ${REPO}
# chezmoi init --apply --source-path ${DOTFILES}
