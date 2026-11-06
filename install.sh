#!/usr/bin/env bash

set -eu

# chezmoi がインストールされていない場合はインストール
if [ ! "$(command -v chezmoi)" ]; then
  BIN="${HOME}/.local/bin"
  CHEZMOI="${BIN}/chezmoi"
  # curl か wget がインストールされている場合は chezmoi をインストール
  if [ "$(command -v curl)" ]; then
    sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "${BIN}"
  elif [ "$(command -v wget)" ]; then
    sh -c "$(wget -qO- https://get.chezmoi.io)" -- -b "${BIN}"
  else
    echo "To install chezmoi, you must have curl or wget installed." >&2
    exit 1
  fi
  # $PATH に ~/.local/bin がなければ追加
  if ! echo "${PATH}" | grep -q "${BIN}"; then
    export PATH="${BIN}:${PATH}"
  fi
else
  CHEZMOI=chezmoi
fi

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
SCRIPT_DIR="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"
DOTFILES_DIR="${HOME}/dotfiles"

if [ -e "${DOTFILES_DIR}" ]; then
  EXISTING_DIR="$(cd -P -- "${DOTFILES_DIR}" && pwd -P)" || {
    echo "${DOTFILES_DIR} is not a directory or valid symlink." >&2
    exit 1
  }
  if [ "${EXISTING_DIR}" != "${SCRIPT_DIR}" ]; then
    echo "${DOTFILES_DIR} points to ${EXISTING_DIR}; expected ${SCRIPT_DIR}." >&2
    exit 1
  fi
elif [ -L "${DOTFILES_DIR}" ]; then
  echo "${DOTFILES_DIR} is a broken symlink." >&2
  exit 1
else
  ln -s "${SCRIPT_DIR}" "${DOTFILES_DIR}"
fi

echo "SCRIPT_DIR: ${SCRIPT_DIR}"
"${CHEZMOI}" --version
echo "chezmoi init --apply --source=${DOTFILES_DIR}"

# exec で新たなプロセスを起動して、現在のプロセスを置き換える
exec "${CHEZMOI}" init --apply "--source=${DOTFILES_DIR}"
