#!/usr/bin/env bash
set -eu

BIN="${HOME}/.local/bin"
export PATH="${BIN}:${PATH}"

if ! command -v mise >/dev/null 2>&1; then
    command -v curl >/dev/null 2>&1 || {
        echo "curl is required to install mise" >&2
        exit 1
    }

    mkdir -p "${BIN}"
    curl -fsSL https://mise.run |
        MISE_INSTALL_PATH="${BIN}/mise" sh

    export MISE_CONFIG_DIR="${HOME}/.config/mise"
    mkdir -p "${MISE_CONFIG_DIR}"
    eval "$(mise activate bash)"
fi

mise --version
