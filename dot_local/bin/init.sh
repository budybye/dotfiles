#!/usr/bin/env bash
set -ex

GIT_USER="${GIT_AUTHOR_NAME:--S .}"

echo "### chezmoi のインストールを開始します..."
if ! command -v chezmoi >/dev/null 2>&1; then
    sh -c "$(curl -fsLS chezmoi.io/get)" -- init --apply "${GIT_USER}" || {
        echo "### chezmoi のインストールに失敗しました。"
        exit 1
    }
    echo "### chezmoi のインストールが完了しました。"
    "$(pwd)"/bin/chezmoi help
else
    echo "### chezmoi がすでにインストールされています。"
    chezmoi cd && chezmoi init --apply "${GIT_USER}"
fi
