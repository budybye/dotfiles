#!/usr/bin/env bash
set -ex

GIT_USER="${GIT_AUTHOR_NAME:--S .}"

if ! command -v chezmoi >/dev/null 2>&1; then
    sh -c "$(curl -fsLS chezmoi.io/get)" -- init --apply "${GIT_USER}" || {
        echo "### chezmoi のインストールに失敗しました。"
        exit 1
    }
    "$(pwd)"/bin/chezmoi help
else
    echo "### chezmoi がすでにインストールされています。"
    chezmoi cd && chezmoi init --apply "${GIT_USER}"
fi
ls -la "${HOME}"
ls -la "${HOME}/.local/bin"
ls -la "${XDG_CONFIG_HOME:-$HOME/.config}"
ls -la "${XDG_DATA_HOME:-$HOME/.local/share}"
