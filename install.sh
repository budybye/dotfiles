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

# PATH に ~/.local/bin がなければ追加
if ! echo "${PATH}" | grep -q "${BIN}"; then
    export PATH=${BIN}:$PATH
    chezmoi --version
fi

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
SCRIPT_DIR="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"
echo "SCRIPT_DIR: $SCRIPT_DIR"

# exec: replace current process with chezmoi init
exec "$CHEZMOI" init --apply "--source=$SCRIPT_DIR"
# exec "$CHEZMOI" init --apply "--source=$SCRIPT_DIR" --verbose
