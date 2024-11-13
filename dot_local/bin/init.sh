#!/usr/bin/env bash
set -ex

GIT_USER="${GIT_AUTHOR_NAME:--S .}"

echo "chezmoi install start..."
if ! command -v chezmoi >/dev/null 2>&1; then
    sh -c "$(curl -fsLS chezmoi.io/get)" -- init --apply "${GIT_USER}" || {
        echo "chezmoi install failed."
        exit 1
    }
    echo "chezmoi install && init completed."
    "$(pwd)"/bin/chezmoi help
else
    echo "chezmoi already installed."
    chezmoi cd && chezmoi init --apply "${GIT_USER}"
    chezmoi help
fi

ls -la "${HOME}/.local/share/chezmoi"
