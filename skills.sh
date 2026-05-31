#!/usr/bin/env bash

# 直接実行時のみ set -e（source 時は親シェルを閉じないように）
if [ -n "${BASH_SOURCE[0]:-}" ] && [ "${BASH_SOURCE[0]}" = "${0:-}" ]; then
    set -e
fi

command -v npx >/dev/null 2>&1 || { printf '%s\n' 'skills.sh: not found command npx' >&2; exit 1; }

tmp="./skills-list.md"
out="${1:-${tmp}}"
mkdir -p "$(dirname "${out}")"
npx --yes skills ls -g 2>&1 | sed 's/\x1B\[[0-9;]*[mK]//g' > "${out}"
printf '%s\n' "→ ${out}"
