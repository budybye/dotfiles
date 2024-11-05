#!/usr/bin/env bash
set -ex

GIT_USER="${GIT_AUTHOR_NAME:-budybye}"

if ! command -v chezmoi >/dev/null 2>&1; then
    sh -c "$(curl -fsLS chezmoi.io/get)" -- init --apply ${GIT_USER} || {
        echo "### chezmoi のインストールに失敗しました。"
        exit 1
    }
    "$(pwd)"/bin/chezmoi help
else
    echo "### chezmoi がすでにインストールされています。"
    chezmoi init --apply ${GIT_USER}
fi
ls -la ${HOME}
ls -la ${HOME}/.local/bin
ls -la ${XDG_CONFIG_HOME}
ls -la ${XDG_DATA_HOME}
