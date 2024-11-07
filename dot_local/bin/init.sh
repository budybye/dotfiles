#!/usr/bin/env bash
set -ex

GIT_USER="${GIT_AUTHOR_NAME:--S .}"

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
echo "### ファイルの確認を開始します..."

echo "### ${HOME} の中身"
ls -la "${HOME}"

echo "### ${HOME}/.config の中身"
ls -la "${HOME}/.config"

echo "### ${HOME}/.local/bin の中身"
ls -la "${HOME}/.local/bin"

echo "### ${HOME}/.local/share の中身"
ls -la "${HOME}/.local/share"

echo "### ${HOME}/.local/share/chezmoi の中身"
ls -la "${HOME}/.local/share/chezmoi"
