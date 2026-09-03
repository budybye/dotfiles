#!/usr/bin/env bash

set -eu

env

ls -a "${HOME}"

ls -a "${HOME}/dotfiles"

mise dr || true

chezmoin doctor || true

xrp