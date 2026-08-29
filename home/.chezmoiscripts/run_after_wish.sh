#!/usr/bin/env bash
set -eu

DOTFILES_DIR="${HOME}/dotfiles"
SOURCE_DIR="$(chezmoi source-path)"
SOURCE_DIR="$(cd -P -- "${SOURCE_DIR}" && pwd -P)"

if [ -e "${DOTFILES_DIR}" ]; then
    EXISTING_DIR="$(cd -P -- "${DOTFILES_DIR}" && pwd -P)" || {
        echo "${DOTFILES_DIR} is not a directory or valid symlink." >&2
        exit 1
    }
    if [ "${EXISTING_DIR}" != "${SOURCE_DIR}" ]; then
        echo "${DOTFILES_DIR} points to ${EXISTING_DIR}; expected ${SOURCE_DIR}." >&2
        exit 1
    fi
elif [ -L "${DOTFILES_DIR}" ]; then
    echo "${DOTFILES_DIR} is a broken symlink." >&2
    exit 1
else
    ln -s "${SOURCE_DIR}" "${DOTFILES_DIR}"
fi
