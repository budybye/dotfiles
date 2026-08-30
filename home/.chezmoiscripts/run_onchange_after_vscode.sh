#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="${HOME}/dotfiles/home/private_dot_config/Code/user-data/User"

case "$(uname -s)" in
  Darwin)
    CURSOR_DIR="${HOME}/Library/Application Support/Cursor"
    ;;
  Linux)
    CURSOR_DIR="${HOME}/.config/Cursor"
    ;;
  *)
    exit 0
    ;;
esac

if ! command -v cursor >/dev/null 2>&1 && [ ! -d "${CURSOR_DIR}" ]; then
  echo "Cursor not installed; skipping Cursor config links."
  exit 0
fi

mkdir -p "${CURSOR_DIR}/User"

link_json_file() {
  local json_type="$1"
  local source_file="${SOURCE_DIR}/${json_type}.json"
  local target_file="${CURSOR_DIR}/User/${json_type}.json"

  if [ ! -f "${source_file}" ]; then
    echo "Cursor source file not found: ${source_file}" >&2
    exit 1
  fi

  if [ -L "${target_file}" ]; then
    if [ "$(readlink "${target_file}")" = "${source_file}" ]; then
      return
    fi
    rm -f "${target_file}"
  elif [ -e "${target_file}" ]; then
    mv "${target_file}" "${target_file}.old"
  fi

  ln -s "${source_file}" "${target_file}"
  echo "linked ${target_file}"
}

# Extension installation is disabled.
# Dev Container extensions are managed by .devcontainer/devcontainer.json.
# code --install-extension is intentionally not executed.

link_json_file "settings"
link_json_file "keybindings"

