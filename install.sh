#! /usr/bin/env bash

USER=$(whoami)
BIN=${HOME}/.local/bin

echo "USER: ${USER}"

if ! command -v chezmoi >/dev/null 2>&1; then
    echo "${USER} install chezmoi to ${BIN}..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${BIN}"
    export PATH="${BIN}:$PATH"
fi

if [ "${USER}" == "dev" ]; then
    chezmoi init --apply --source-path ${HOME}/dotfiles

elif [ -f ${HOME}/dotfiles/.chezmoi.yaml.tmpl ]; then
    chezmoi init --apply --source-path ${HOME}/dotfiles

else
    chezmoi init --apply budybye
fi
