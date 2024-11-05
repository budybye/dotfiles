#!/usr/bin/env bash
set -ex

GIT_USER="${GIT_AUTHOR_NAME:-budybye}"

pwd
ls -la
# sh -c "$(curl -fsLS chezmoi.io/get)" -- init --apply -S .
sh -c "$(curl -fsLS chezmoi.io/get)" -- init --apply ${GIT_USER}
ls -la ${HOME}
ls -la ${HOME}/.local/bin
ls -la ${HOME}/.config
ls -la ${HOME}/.local/share/
"$(pwd)"/bin/chezmoi help
