#!/usr/bin/env bash
set -ex
# make から実行された場合は、gitpull をしないでapply する
if [ "$(pwd)" != "${HOME}/dotfiles" ] && [ "$(pwd)" != "${HOME}/.local/share/chezmoi" ]; then
    GIT_USER="budybye"
else
    GIT_USER="-S ."
fi

echo "chezmoi install start..."
command -v chezmoi >/dev/null || sh -c "$(curl -fsLS chezmoi.io/get)" -- -b ${HOME}/.local/bin || {
        echo "chezmoi install failed."
        exit 1
    }
chezmoi init --apply "${GIT_USER}"
echo "chezmoi install && init completed."
