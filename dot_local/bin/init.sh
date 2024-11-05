#!/usr/bin/env bash
set -ex

GIT_USER="${GIT_AUTHOR_NAME:-budybye}"

pwd
ls -la
# sh -c "$(curl -fsLS chezmoi.io/get)" -- init --apply -S .
sh -c "$(curl -fsLS chezmoi.io/get)" -- init --apply ${GIT_USER}
ls -la ${HOME}
ls -la ${HOME}/.local/bin
ls -la ${XDG_CONFIG_HOME}
ls -la ${XDG_DATA_HOME}
"$(pwd)"/bin/chezmoi help
