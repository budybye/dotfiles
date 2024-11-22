#! /usr/bin/env bash

# chezmoi のインストールと初期化

AUTHOR=budybye
USER=$(whoami)
BIN=${HOME}/.local/bin
DOTFILES=${HOME}/dotfiles

echo "USER: ${USER}"
pwd

# chezmoi がインストールされていない場合はインストール
if ! command -v chezmoi >/dev/null 2>&1; then
    echo "${USER} install chezmoi to ${BIN}..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${BIN}"
    export PATH="${BIN}:$PATH"
fi
echo "--------------------------------"
# devcontainer か dotfiles がある場合は source-path を指定
if [ "${USER}" == "dev" ] || [ -f ${DOTFILES}/.chezmoi.toml ]; then
    chezmoi init --apply --source-path ${DOTFILES}
else
    chezmoi init --apply ${AUTHOR}
    # chezmoi init --apply git@github.com:${AUTHOR}/dotfiles.git
fi

# chezmoi 用の環境変数を指定 例: dev, runner, lisa,  etc...
export CONTEXT=${USER}
