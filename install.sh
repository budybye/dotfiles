#!/usr/bin/env bash

set -e # -e: exit on error

if [ ! "$(command -v chezmoi)" ]; then
    BIN="$HOME/.local/bin"
    CHEZMOI="$BIN/chezmoi"
    if [ "$(command -v curl)" ]; then
        sh -c "$(curl -fsSL https://git.io/chezmoi)" -- -b "$BIN"
    elif [ "$(command -v wget)" ]; then
        sh -c "$(wget -qO- https://git.io/chezmoi)" -- -b "$BIN"
    else
        echo "To install chezmoi, you must have curl or wget installed." >&2
        exit 1
    fi
else
    CHEZMOI=chezmoi
fi

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
SCRIPT_DIR="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"
echo "SCRIPT_DIR: $SCRIPT_DIR"

if [ -z "$BW_SESSION" ]; then
    echo "BW_SESSION is not set."
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "GITHUB_TOKEN is not set."
fi

# exec: replace current process with chezmoi init
exec "$CHEZMOI" init --apply "--source=$SCRIPT_DIR"
# exec "$CHEZMOI" init --apply "--source=$SCRIPT_DIR" --verbose
