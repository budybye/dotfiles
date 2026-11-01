#!/usr/bin/env bash
set -eu

# 診断出力のみ。mise dr / chezmoi doctor / xrp(外部 xrpl.ws) の失敗で
# test → tag → push のリリース連鎖を止めないよう、診断コマンドは非致命にする。
echo "Watch CI"
echo "--------------------------------"
# 値はシークレットを含むため変数名のみ出力(複数行の値の 2 行目以降を出さないよう env | cut は使わない)
compgen -e | sort
echo "--------------------------------"
ls -a "${HOME}"
echo "--------------------------------"
ls -a "${HOME}/dotfiles" || true
echo "--------------------------------"
mise dr || true
echo "--------------------------------"
chezmoi doctor || true
echo "--------------------------------"
xrp || true