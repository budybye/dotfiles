#! /usr/bin/env bash

USER=budybye
BIN=${HOME}/.local/bin

echo "pwd: $(pwd)"
echo "${USER} install chezmoi to ${BIN}..."

if ! command -v chezmoi >/dev/null 2>&1; then
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${BIN}"
    export PATH="${BIN}:$PATH"
fi

chezmoi init --apply ${USER}
# chezmoi init --apply --verbose ${USER}
# chezmoi init --apply --source-path ${HOME}/dotfiles
